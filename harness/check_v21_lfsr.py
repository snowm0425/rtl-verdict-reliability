"""Re-run the LFSR candidates against the RTLLM v2.1 harness.

v2.0 instantiates the DUT by port position; v2.1 uses named connections.
Set RTLLM21_DIR to a clone of RTLLM at tag v2.1 (commit 51ed553).
"""
import os, subprocess, shutil, tempfile, glob, yaml
from pathlib import Path
from harness.config import RTLLM, ROOT, IVERILOG, VVP, IV_FLAGS
from harness.run_tb import verdict

V21_ROOT = Path(os.environ.get("RTLLM21_DIR", "/tmp/rtllm21"))

cat = yaml.safe_load(open(ROOT/"catalog.yaml"))
e = cat["LFSR"]
PASS_STR = e.get("pass_string")
V20 = RTLLM/e["testbench"]
V21 = V21_ROOT/"Memory/Shifter/LFSR/testbench.v"
SRC = V20.parent

cands = sorted(glob.glob(str(ROOT/"results/generated/*/LFSR/s*.v")))
print(f"pass_string: {PASS_STR!r}")
print(f"candidates: {len(cands)}\n")

for tag, tb in (("v2.0", V20), ("v2.1", V21)):
    npass, detail = 0, []
    for c in cands:
        model, stem = Path(c).parts[-3], Path(c).stem
        with tempfile.TemporaryDirectory() as wd:
            wd = Path(wd)
            for p in SRC.iterdir():
                if p.is_file() and p.suffix.lower() not in (".v", ".sv"):
                    shutil.copy2(p, wd/p.name)
            shutil.copy2(c, wd/"cand.v"); shutil.copy2(tb, wd/"tb.v")
            r = subprocess.run([str(IVERILOG), *IV_FLAGS, "-o", "a.vvp", "cand.v", "tb.v"],
                               capture_output=True, text=True, cwd=wd, timeout=120)
            if r.returncode:
                detail.append((model, stem, "compile")); continue
            try:
                sm = subprocess.run([str(VVP), "a.vvp"], capture_output=True,
                                    text=True, cwd=wd, timeout=120)
            except subprocess.TimeoutExpired:
                detail.append((model, stem, "timeout")); continue
            res = {"stage": "sim", "rc": sm.returncode, "stdout": sm.stdout, "stderr": ""}
            if verdict(res, PASS_STR) == "pass": npass += 1
            else: detail.append((model, stem, "fail"))
    print(f"{tag}: {npass}/{len(cands)} pass")
    for d in detail: print("   ", *d)
    print()
