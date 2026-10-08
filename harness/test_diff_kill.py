# harness/test_diff_kill.py
import yaml, subprocess, shutil
from harness.config import RTLLM, ROOT, SCRATCH, IVERILOG, VVP, IV_FLAGS
from harness.diff_wrapper import build_wrapper, diff_verdict

cat = yaml.safe_load(open(ROOT/"catalog.yaml"))
MUT = ROOT/"results"/"mutants"

for name in ["adder_8bit", "comparator_4bit", "counter_12", "fsm"]:
    e = cat[name]
    ref = (RTLLM/e["golden_file"]).read_text()
    for mf in sorted((MUT/name).glob("*.v")):
        mut_src = mf.read_text()
        # mutant 的模組名是 golden_module，要改成 tb_expects 才能當 candidate 例化
        from harness.verilog_text import rename_module
        dut = rename_module(mut_src, e["golden_module"] or name, e["tb_expects"]) \
              if e["alias_needed"] else mut_src
        tb = build_wrapper(e, ref, dut, seed=1)

        wd = SCRATCH/"diffkill"/name/mf.stem
        if wd.exists(): shutil.rmtree(wd)
        wd.mkdir(parents=True)
        (wd/"t.v").write_text(tb)
        c = subprocess.run([str(IVERILOG), *IV_FLAGS, "-o","a.vvp","t.v"],
                           capture_output=True, text=True, cwd=wd)
        if c.returncode:
            print(f"  COMPILE-ERR {name}/{mf.stem}"); continue
        s = subprocess.run([str(VVP),"a.vvp"], capture_output=True, text=True, cwd=wd, timeout=60)
        v = diff_verdict(s.stdout)
        # differential 要 FAIL 才代表「抓到 mutant」
        print(f"  {'KILLED' if v=='fail' else 'SURVIVED':9s} {name}/{mf.stem}")
