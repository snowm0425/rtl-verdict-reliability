from pathlib import Path

ROOT       = Path.home() / "Documents" / "syn"
RTLLM      = ROOT / "RTLLM"                    # 唯讀
GATETRUTH  = ROOT / "GateTruth"
RESULTS    = ROOT / "results"
SCRATCH    = ROOT / "scratch"

IVERILOG   = ROOT / "iv12" / "bin" / "iverilog"
VVP        = ROOT / "iv12" / "bin" / "vvp"
IV_FLAGS   = ["-g2012"]
