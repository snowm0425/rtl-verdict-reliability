import csv, yaml, random, subprocess, shutil, math
from harness.config import RTLLM, ROOT, SCRATCH, IVERILOG, VVP, IV_FLAGS
from harness.diff_wrapper import build_wrapper

cat = yaml.safe_load(open(ROOT/"catalog.yaml"))
for _n,_e in cat.items(): _e["_name"] = _n
EXCL = {"LIFObuffer","RAM","fixed_point_adder","fixed_point_substractor"}
POS  = {"LFSR","alu","float_multi","pe"}
rows = [r for r in csv.DictReader(open(ROOT/"results/dual_verdicts.csv"))
        if r["design"] not in EXCL]

# ── 1. 門檻 sensitivity ────────────────────────────────
print("=== 1. threshold sensitivity ===")
per = {}
for n in sorted({r["design"] for r in rows}):
    tbp = [r for r in rows if r["design"]==n and r["verdict_tb"]=="pass"]
    if len(tbp) >= 3:
        per[n] = (cat[n]["kill_rate"],
                  sum(r["verdict_diff"]=="fail" for r in tbp)/len(tbp))
fp = [k for k,(_,f) in per.items() if f > 0]
print(f"  designs with any false-pass: {len(fp)}/{len(per)}")
print(f"  MAX kill_rate among them: {max(per[k][0] for k in fp):.1f}%  <- 免門檻陳述用這個")
from scipy.stats import fisher_exact
for th in (100, 95, 90, 85, 84):
    hi = [k for k,(kr,_) in per.items() if kr >= th]
    lo = [k for k in per if k not in hi]
    a = sum(per[k][1] > 0 for k in hi); b = sum(per[k][1] > 0 for k in lo)
    p = fisher_exact([[a, len(hi)-a],[b, len(lo)-b]])[1]
    print(f"  >={th:3d}%: {a}/{len(hi)} vs {b}/{len(lo)} false-pass   Fisher p={p:.4f}")

# ── 2. bootstrap CI（以設計為單位重抽，樣本間相關）──────
print("\n=== 2. bootstrap 95% CI (cluster bootstrap over designs, B=10000) ===")
def rates(rs):
    tp = [r for r in rs if r["verdict_tb"]=="pass"]
    tf = [r for r in rs if r["verdict_tb"]=="fail"]
    return (sum(r["verdict_diff"]=="fail" for r in tp)/len(tp) if tp else None,
            sum(r["verdict_diff"]=="pass" for r in tf)/len(tf) if tf else None)

def ci(subset, label):
    designs = sorted({r["design"] for r in subset})
    by = {d:[r for r in subset if r["design"]==d] for d in designs}
    pt = rates(subset)
    rnd = random.Random(20260826); fps, ffs = [], []
    for _ in range(10000):
        samp = [r for d in [rnd.choice(designs) for _ in designs] for r in by[d]]
        a,b = rates(samp)
        if a is not None: fps.append(a)
        if b is not None: ffs.append(b)
    q = lambda v,p: sorted(v)[int(p*len(v))]
    print(f"  {label}")
    print(f"    false-pass {100*pt[0]:5.1f}%  [{100*q(fps,.025):.1f}, {100*q(fps,.975):.1f}]")
    print(f"    false-fail {100*pt[1]:5.1f}%  [{100*q(ffs,.025):.1f}, {100*q(ffs,.975):.1f}]")

ci([r for r in rows if r["design"] not in POS], "general designs (38)")
ci([r for r in rows if r["design"] in POS],     "positional binding (4)")
for m in sorted({r["model"] for r in rows}):
    ci([r for r in rows if r["model"]==m and r["design"] not in POS], m)

# ── 3. square_wave case study 素材 ─────────────────────
print("\n=== 3. square_wave case study ===")
e = cat["square_wave"]
ref = (RTLLM/e["golden_file"]).read_text()
for tag in ("qwen25-coder-32b","qwen38-27b"):
    for f in sorted((ROOT/"results/generated"/tag/"square_wave").glob("s??.v")):
        row = [r for r in csv.DictReader(open(ROOT/"results/dual_verdicts.csv"))
               if r["model"]==tag and r["design"]=="square_wave" and r["sample"]==f.stem]
        if not row or row[0]["verdict_tb"]!="pass" or row[0]["verdict_diff"]!="fail":
            continue
        wd = SCRATCH/"case"; shutil.rmtree(wd, ignore_errors=True); wd.mkdir(parents=True)
        (wd/"t.v").write_text(build_wrapper(e, ref, f.read_text(), seed=1))
        subprocess.run([str(IVERILOG),*IV_FLAGS,"-o","a.vvp","t.v"],cwd=wd,capture_output=True)
        s = subprocess.run([str(VVP),"a.vvp"],capture_output=True,text=True,cwd=wd,timeout=90)
        print(f"  --- {tag}/{f.stem} (TB=pass, DIFF=fail) ---")
        print("  " + "\n  ".join(s.stdout.strip().splitlines()[:7]))
        print(f"  candidate has 'initial': {'initial' in f.read_text()}")
        out = ROOT/"results"/"case_square_wave.txt"
        out.write_text(f"# {tag}/{f.stem}\n\n## REFERENCE\n{ref}\n\n## CANDIDATE\n{f.read_text()}\n\n## DIFF OUTPUT\n{s.stdout}")
        print(f"  -> saved {out}")
        raise SystemExit
