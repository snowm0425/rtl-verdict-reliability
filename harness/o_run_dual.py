# 把 460 個候選餵進兩個 oracle，算 inflation
import yaml, json, subprocess, shutil, csv
from collections import defaultdict
from harness.config import RTLLM, ROOT, SCRATCH, IVERILOG, VVP, IV_FLAGS, GATETRUTH
from harness.diff_wrapper import build_wrapper, diff_verdict
from harness.verilog_text import rename_module

cat = yaml.safe_load(open(ROOT/"catalog.yaml"))
GEN = ROOT/"results"/"generated"
OUT = ROOT/"results"
K = 10

# LIFObuffer 在 differential 上排除（Day 1 已知）
DIFF_EXCLUDE = {"LIFObuffer"}

def run_tb(e, cand_src, wd):
    """原 testbench 判定：候選解 + 原 testbench。"""
    if wd.exists(): shutil.rmtree(wd)
    wd.mkdir(parents=True)
    for p in (RTLLM/e["testbench"]).parent.iterdir():
        if p.is_file() and p.suffix.lower() not in (".v", ".sv"):
            shutil.copy2(p, wd/p.name)
    (wd/"cand.v").write_text(cand_src)
    tb = RTLLM/e["testbench"]
    c = subprocess.run([str(IVERILOG),*IV_FLAGS,"-o","a.vvp","cand.v",str(tb)],
                       capture_output=True, text=True, cwd=wd, timeout=60)
    if c.returncode:
        return "fail"
    try:
        s = subprocess.run([str(VVP),"a.vvp"], capture_output=True, text=True, cwd=wd, timeout=60)
    except subprocess.TimeoutExpired:
        return "fail"
    ps = e.get("pass_string")
    if not ps or s.returncode != 0:
        return "fail"
    return "pass" if ps in s.stdout.splitlines() else "fail"

def run_diff(e, ref_src, cand_src, wd):
    """differential 判定：候選解 vs golden。"""
    if wd.exists(): shutil.rmtree(wd)
    wd.mkdir(parents=True)
    for p in (RTLLM/e["testbench"]).parent.iterdir():
        if p.is_file() and p.suffix.lower() not in (".v", ".sv"):
            shutil.copy2(p, wd/p.name)
    tb = build_wrapper(e, ref_src, cand_src, seed=1)
    (wd/"t.v").write_text(tb)
    c = subprocess.run([str(IVERILOG),*IV_FLAGS,"-o","a.vvp","t.v"],
                       capture_output=True, text=True, cwd=wd, timeout=60)
    if c.returncode:
        return "fail"
    try:
        s = subprocess.run([str(VVP),"a.vvp"], capture_output=True, text=True, cwd=wd, timeout=90)
    except subprocess.TimeoutExpired:
        return "fail"
    return diff_verdict(s.stdout)

rows = []
for name in sorted(cat):
    e = cat[name]
    if e["status"] != "audited":
        continue
    ref = (RTLLM/e["golden_file"]).read_text()
    for k in range(K):
        f = GEN/name/f"s{k:02d}.v"
        if not f.exists():
            continue
        cand = f.read_text()

        tb_v = run_tb(e, cand, SCRATCH/"dual_tb"/name/f"s{k:02d}")

        if name in DIFF_EXCLUDE:
            diff_v = "excluded"
        else:
            diff_v = run_diff(e, ref, cand, SCRATCH/"dual_diff"/name/f"s{k:02d}")

        rows.append({"design": name, "sample": k,
                     "verdict_tb": tb_v, "verdict_diff": diff_v})
    # per-design 進度
    tb_p  = sum(r["verdict_tb"]=="pass"   for r in rows if r["design"]==name)
    df_p  = sum(r["verdict_diff"]=="pass" for r in rows if r["design"]==name)
    print(f"{name:26s} tb_pass={tb_p}/{K}  diff_pass={df_p}/{K}", flush=True)

with open(OUT/"dual_verdicts.csv","w",newline="") as fh:
    w = csv.DictWriter(fh, ["design","sample","verdict_tb","verdict_diff"])
    w.writeheader(); w.writerows(rows)

# ---- RQ1: inflation ----
print("\n=== RQ1: inflation per design ===")
gt = {}
for name in sorted(cat):
    e = cat[name]
    if e["status"]!="audited" or name in DIFF_EXCLUDE:
        continue
    d = [r for r in rows if r["design"]==name]
    n = len(d)
    tb_pass   = sum(r["verdict_tb"]=="pass"   for r in d)
    diff_pass = sum(r["verdict_diff"]=="pass" for r in d)
    infl = (tb_pass - diff_pass) / n if n else 0
    kr = e["kill_rate"]
    gt[name] = (kr, infl, tb_pass, diff_pass, n)
    print(f"  {name:26s} kill_rate={kr:5.1f}  tb={tb_pass}/{n}  diff={diff_pass}/{n}  inflation={infl:+.2f}")

# 總體
tot_tb   = sum(v[2] for v in gt.values())
tot_diff = sum(v[3] for v in gt.values())
tot_n    = sum(v[4] for v in gt.values())
print(f"\n=== SUMMARY (excl. {DIFF_EXCLUDE}) ===")
print(f"overall pass@1  original TB:   {tot_tb}/{tot_n} ({100*tot_tb/tot_n:.1f}%)")
print(f"overall pass@1  differential:  {tot_diff}/{tot_n} ({100*tot_diff/tot_n:.1f}%)")
print(f"inflation (TB - diff):         {100*(tot_tb-tot_diff)/tot_n:+.1f} pp")

# RQ1 相關性（需要 scipy，沒有就跳過）
try:
    from scipy.stats import spearmanr
    krs  = [v[0] for v in gt.values()]
    infl = [v[1] for v in gt.values()]
    rho, p = spearmanr(krs, infl)
    print(f"\nRQ1 Spearman(kill_rate, inflation): rho={rho:.3f}  p={p:.4f}")
    print("  （負相關 = testbench 越弱、inflation 越大，符合假設）")
except ImportError:
    print("\n(scipy 未安裝，RQ1 相關性稍後算：pip install scipy)")
