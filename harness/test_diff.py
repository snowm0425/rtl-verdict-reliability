# harness/test_diff.py
import yaml, subprocess, shutil
from harness.config import RTLLM, ROOT, SCRATCH, IVERILOG, VVP, IV_FLAGS
from harness.diff_wrapper import build_wrapper, diff_verdict

cat = yaml.safe_load(open(ROOT/"catalog.yaml"))
for name in ["adder_8bit", "comparator_4bit", "counter_12", "fsm"]:
    e = cat[name]
    src = (RTLLM/e["golden_file"]).read_text()
    from harness.verilog_text import rename_module
    dut = rename_module(src, e["golden_module"] or name, e["tb_expects"]) \
          if e["alias_needed"] else src
    tb = build_wrapper(e, src, dut, seed=1)

    wd = SCRATCH/"diff"/name
    if wd.exists(): shutil.rmtree(wd)
    wd.mkdir(parents=True)
    (wd/"diff_tb.v").write_text(tb)
    c = subprocess.run([str(IVERILOG), *IV_FLAGS, "-o", "a.vvp", "diff_tb.v"],
                       capture_output=True, text=True, cwd=wd)
    if c.returncode: print(f"FAIL {name} compile\n{c.stderr[:400]}"); continue
    s = subprocess.run([str(VVP), "a.vvp"], capture_output=True, text=True, cwd=wd, timeout=60)
    print(f"{diff_verdict(s.stdout):5s} {name}: {s.stdout.strip()[:120]}")
