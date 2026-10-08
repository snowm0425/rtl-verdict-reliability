import yaml, subprocess, shutil, csv, sys
from harness.config import RTLLM, ROOT, SCRATCH, IVERILOG, VVP, IV_FLAGS
from harness.diff_wrapper import build_wrapper, diff_verdict

cat = yaml.safe_load(open(ROOT/"catalog.yaml"))
for _n, _e in cat.items():
    _e["_name"] = _n
GEN = ROOT/"results"/"generated"
EXCL = {"LIFObuffer"}
SEEDS = [1, 2, 3]

def run_diff(e, ref, cand, wd, seed):
    if wd.exists(): shutil.rmtree(wd)
    wd.mkdir(parents=True)
    for p in (RTLLM/e["testbench"]).parent.iterdir():
        if p.is_file() and p.suffix.lower() not in (".v", ".sv"):
            shutil.copy2(p, wd/p.name)
    (wd/"t.v").write_text(build_wrapper(e, ref, cand, seed=seed))
    try:
        c = subprocess.run([str(IVERILOG),*IV_FLAGS,"-o","a.vvp","t.v"],
                           capture_output=True, text=True, cwd=wd, timeout=60)
        if c.returncode: return "fail"
        s = subprocess.run([str(VVP),"a.vvp"], capture_output=True, text=True, cwd=wd, timeout=90)
    except subprocess.TimeoutExpired:
        return "fail"
    return diff_verdict(s.stdout)

rows = []
for tag in sorted(p.name for p in GEN.iterdir() if p.is_dir()):
    for name in sorted(cat):
        e = cat[name]
        if e["status"] != "audited" or name in EXCL: continue
        ref = (RTLLM/e["golden_file"]).read_text()
        for f in sorted((GEN/tag/name).glob("s??.v")):
            cand = f.read_text()
            r = {"model": tag, "design": name, "sample": f.stem}
            for sd in SEEDS:
                r[f"seed{sd}"] = run_diff(e, ref, cand, SCRATCH/"seed"/tag/name/f"{f.stem}_s{sd}", sd)
            rows.append(r)
        print(f"  {tag}/{name}", flush=True)

with open(ROOT/"results"/"seed_stability.csv","w",newline="") as fh:
    w = csv.DictWriter(fh, ["model","design","sample"]+[f"seed{s}" for s in SEEDS])
    w.writeheader(); w.writerows(rows)

# ---- 摘要 ----
print("\n=== differential pass rate by seed ===")
for tag in sorted({r["model"] for r in rows}):
    rs = [r for r in rows if r["model"]==tag]
    n = len(rs)
    line = f"  {tag:22s} n={n}  "
    for sd in SEEDS:
        p = sum(r[f"seed{sd}"]=="pass" for r in rs)
        line += f"seed{sd}={p}({100*p/n:.1f}%)  "
    print(line)

unstable = [r for r in rows if len({r[f"seed{s}"] for s in SEEDS}) > 1]
print(f"\nverdict-unstable samples: {len(unstable)}/{len(rows)} ({100*len(unstable)/len(rows):.1f}%)")
for r in unstable[:20]:
    print(f"  {r['model']}/{r['design']}/{r['sample']}: " +
          " ".join(f"{r[f'seed{s}']}" for s in SEEDS))
