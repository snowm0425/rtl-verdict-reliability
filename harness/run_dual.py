import yaml, subprocess, shutil, csv, sys
from harness.config import RTLLM, ROOT, SCRATCH, IVERILOG, VVP, IV_FLAGS
from harness.diff_wrapper import build_wrapper, diff_verdict

cat = yaml.safe_load(open(ROOT/"catalog.yaml"))
for _n, _e in cat.items():
    _e["_name"] = _n
GEN = ROOT/"results"/"generated"
OUT = ROOT/"results"

#DIFF_EXCLUDE = {"LIFObuffer"}          # Day1: EN-gated reset, memory array
DIFF_EXCLUDE = {
    "LIFObuffer",              # EN-gated reset + memory array，初始狀態無法對齊
    "fixed_point_adder",       # 規格未指定定點數表示法
    "fixed_point_substractor", # 同上
    "RAM",                     # golden 宣告深度 12/寬度 8，與規格的 8/6 不符
}

def run_tb(e, cand_src, wd):
    if wd.exists(): shutil.rmtree(wd)
    wd.mkdir(parents=True)
    for p in (RTLLM/e["testbench"]).parent.iterdir():
        if p.is_file() and p.suffix.lower() not in (".v", ".sv"):
            shutil.copy2(p, wd/p.name)
    (wd/"cand.v").write_text(cand_src)
    try:
        c = subprocess.run([str(IVERILOG),*IV_FLAGS,"-o","a.vvp","cand.v",str(RTLLM/e["testbench"])],
                           capture_output=True, text=True, cwd=wd, timeout=60)
        if c.returncode: return "fail"
        s = subprocess.run([str(VVP),"a.vvp"], capture_output=True, text=True, cwd=wd, timeout=60)
    except subprocess.TimeoutExpired:
        return "fail"
    ps = e.get("pass_string")
    if not ps or s.returncode != 0: return "fail"
    return "pass" if ps in s.stdout.splitlines() else "fail"

def run_diff(e, ref_src, cand_src, wd):
    if wd.exists(): shutil.rmtree(wd)
    wd.mkdir(parents=True)
    for p in (RTLLM/e["testbench"]).parent.iterdir():
        if p.is_file() and p.suffix.lower() not in (".v", ".sv"):
            shutil.copy2(p, wd/p.name)
    (wd/"t.v").write_text(build_wrapper(e, ref_src, cand_src, seed=1))
    try:
        c = subprocess.run([str(IVERILOG),*IV_FLAGS,"-o","a.vvp","t.v"],
                           capture_output=True, text=True, cwd=wd, timeout=60)
        if c.returncode: return "fail"
        s = subprocess.run([str(VVP),"a.vvp"], capture_output=True, text=True, cwd=wd, timeout=90)
    except subprocess.TimeoutExpired:
        return "fail"
    return diff_verdict(s.stdout)

def evaluate(tag):
    rows = []
    for name in sorted(cat):
        e = cat[name]
        if e["status"] != "audited": continue
        #e["_name"] = name          ##
        ref = (RTLLM/e["golden_file"]).read_text()
        for f in sorted((GEN/tag/name).glob("s??.v")):
            k = f.stem
            cand = f.read_text()
            tb_v = run_tb(e, cand, SCRATCH/"d_tb"/tag/name/k)
            df_v = "excluded" if name in DIFF_EXCLUDE else \
                   run_diff(e, ref, cand, SCRATCH/"d_df"/tag/name/k)
            rows.append({"model": tag, "design": name, "sample": k,
                         "verdict_tb": tb_v, "verdict_diff": df_v})
        d = [r for r in rows if r["design"] == name]
        print(f"  {tag}/{name:26s} tb={sum(r['verdict_tb']=='pass' for r in d)}/{len(d)}"
              f"  diff={sum(r['verdict_diff']=='pass' for r in d)}/{len(d)}", flush=True)
    return rows

if __name__ == "__main__":
    tags = sys.argv[1:] or sorted(p.name for p in GEN.iterdir() if p.is_dir())
    all_rows = []
    for tag in tags:
        print(f"=== {tag} ===", flush=True)
        all_rows += evaluate(tag)

    with open(OUT/"dual_verdicts.csv","w",newline="") as fh:
        w = csv.DictWriter(fh, ["model","design","sample","verdict_tb","verdict_diff"])
        w.writeheader(); w.writerows(all_rows)
    print(f"\nwrote {len(all_rows)} rows -> results/dual_verdicts.csv")
