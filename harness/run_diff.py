# harness/run_diff.py
import yaml, subprocess, shutil, csv, json
from harness.config import RTLLM, ROOT, SCRATCH, IVERILOG, VVP, IV_FLAGS, GATETRUTH
from harness.diff_wrapper import build_wrapper, diff_verdict
from harness.verilog_text import rename_module

cat = yaml.safe_load(open(ROOT/"catalog.yaml"))
for _n, _e in cat.items():
    _e["_name"] = _n
MUT = ROOT/"results"/"mutants"
GT  = GATETRUTH/"external-audit/results/rtllm/final-g2012"
OUT = ROOT/"results"; OUT.mkdir(exist_ok=True)

def compile_run(e, ref, dut, tag, cyc=2000):
    tb = build_wrapper(e, ref, dut, seed=1, cycles=cyc)
    wd = SCRATCH/"diff"/tag
    if wd.exists(): shutil.rmtree(wd)
    wd.mkdir(parents=True)
    # 複製輔助檔（$readmemh）
    for p in (RTLLM/e["testbench"]).parent.iterdir():
        if p.is_file() and p.suffix.lower() not in (".v",".sv"):
            shutil.copy2(p, wd/p.name)
    (wd/"t.v").write_text(tb)
    c = subprocess.run([str(IVERILOG),*IV_FLAGS,"-o","a.vvp","t.v"],
                       capture_output=True, text=True, cwd=wd)
    if c.returncode:
        return "compile_err", c.stderr[:300]
    try:
        s = subprocess.run([str(VVP),"a.vvp"], capture_output=True, text=True, cwd=wd, timeout=90)
        return diff_verdict(s.stdout), s.stdout.strip()[:200]
    except subprocess.TimeoutExpired:
        return "timeout", ""

def dut_from(src, e):
    return rename_module(src, e["golden_module"] or e["tb_expects"], e["tb_expects"]) \
           if e["alias_needed"] else src

# ---- Part A: 誤報驗證（golden vs golden）----
print("=== self-consistency (expect all PASS) ===")
self_rows, sc_ok = [], 0
for name in sorted(cat):
    e = cat[name]
    if e["status"] != "audited": continue
    ref = (RTLLM/e["golden_file"]).read_text()
    v, log = compile_run(e, ref, dut_from(ref, e), f"self/{name}")
    self_rows.append({"design": name, "verdict": v, "log": log})
    sc_ok += (v == "pass")
    print(f"  {v:11s} {name}")
print(f"self-consistency: {sc_ok}/{sum(v['status']=='audited' for v in cat.values())} pass")

with open(OUT/"self_consistency.csv","w",newline="") as f:
    csv.DictWriter(f, ["design","verdict","log"]).writeheader()
    csv.DictWriter(f, ["design","verdict","log"]).writerows(self_rows)

# ---- Part B: oracle strength（全 mutant）----
print("\n=== oracle strength (differential vs GateTruth) ===")
rows = []
for name in sorted(cat):
    e = cat[name]
    if e["status"] != "audited": continue
    ref = (RTLLM/e["golden_file"]).read_text()
    gt = {p["id"]: p for p in json.load(open(GT/f"{name}.json"))["per_mutant"]}
    k = 0; tot = 0
    for mf in sorted((MUT/name).glob("*.v")):
        mid = mf.stem
        v, _ = compile_run(e, ref, dut_from(mf.read_text(), e), f"mut/{name}/{mid}")
        killed = (v == "fail")
        rows.append({
            "design": name, "mutant": mid,
            "operator": gt.get(mid,{}).get("operator",""),
            "gt_verdict": gt.get(mid,{}).get("verdict",""),
            "diff_verdict": "killed" if killed else ("survived" if v=="pass" else v),
        })
        k += killed; tot += 1
    print(f"  {name:26s} diff_killed {k}/{tot}")

with open(OUT/"oracle_strength.csv","w",newline="") as f:
    w = csv.DictWriter(f, ["design","mutant","operator","gt_verdict","diff_verdict"])
    w.writeheader(); w.writerows(rows)

# ---- 摘要 ----
killed = sum(r["diff_verdict"]=="killed" for r in rows)
gt_surv = [r for r in rows if r["gt_verdict"]=="survived"]
gt_surv_killed = sum(r["diff_verdict"]=="killed" for r in gt_surv)
print(f"\n=== SUMMARY ===")
print(f"total mutants: {len(rows)}")
print(f"diff killed:   {killed}/{len(rows)} ({100*killed/len(rows):.1f}%)")
print(f"GT-survived that diff KILLED: {gt_surv_killed}/{len(gt_surv)}  ← 核心數字")
