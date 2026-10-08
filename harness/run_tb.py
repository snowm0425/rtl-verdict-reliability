import subprocess, sys, yaml, shutil
from harness.config import RTLLM, ROOT, SCRATCH, IVERILOG, VVP, IV_FLAGS
from harness.verilog_text import alias_golden

def verdict(r, pass_string):
    """GateTruth 規則：exit 0 且 pass banner 為完整一行匹配。"""
    if r["stage"] != "sim" or r["rc"] != 0 or not pass_string:
        return "fail"
    return "pass" if pass_string in r["stdout"].splitlines() else "fail"

def run_one(name, e, workroot):
    wd = workroot / name
    if wd.exists(): shutil.rmtree(wd)
    wd.mkdir(parents=True)
    # testbench 可能用 $readmemh 讀相對路徑的資料檔
    src_dir = (RTLLM / e["testbench"]).parent
    for p in src_dir.iterdir():
        if p.is_file() and p.suffix.lower() not in (".v", ".sv"):
            shutil.copy2(p, wd / p.name)
    ##        

    golden = RTLLM / e["golden_file"]
    tb     = RTLLM / e["testbench"]
    dut = alias_golden(golden, e["golden_module"], e["tb_expects"], wd) \
          if e["alias_needed"] else golden

    vvp_out = wd / "a.vvp"
    c = subprocess.run([str(IVERILOG), *IV_FLAGS, "-o", str(vvp_out), str(dut), str(tb)],
                       capture_output=True, text=True, cwd=wd, timeout=120)
    if c.returncode != 0:
        return {"stage": "compile", "rc": c.returncode, "stdout": "", "stderr": c.stderr[:2000]}

    try:
        s = subprocess.run([str(VVP), str(vvp_out)],
                           capture_output=True, text=True, cwd=wd, timeout=120)
        return {"stage": "sim", "rc": s.returncode, "stdout": s.stdout, "stderr": s.stderr[:2000]}
    except subprocess.TimeoutExpired:
        return {"stage": "sim", "rc": None, "stdout": "", "stderr": "TIMEOUT"}

if __name__ == "__main__":
    cat = yaml.safe_load(open(ROOT / "catalog.yaml"))
    workroot = SCRATCH / "baseline"
    logdir = ROOT / "results" / "baseline_stdout"; logdir.mkdir(parents=True, exist_ok=True)

    ok = fail = 0
    for name, e in sorted(cat.items()):
        r = run_one(name, e, workroot)
        (logdir / f"{name}.txt").write_text(
            f"# stage={r['stage']} rc={r['rc']}\n# STDOUT\n{r['stdout']}\n# STDERR\n{r['stderr']}\n")
        #good = r["stage"] == "sim" and r["rc"] == 0
        v = verdict(r, e.get("pass_string"))
        good = (v == "pass")
        ok, fail = ok + good, fail + (not good)
        print(f"{'OK ' if good else 'FAIL'} {name:26s} {r['stage']}/rc={r['rc']}")
    print(f"\n{ok} ran clean, {fail} failed")
