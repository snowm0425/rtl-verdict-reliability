import re
import yaml
from harness.config import RTLLM, ROOT
from harness.verilog_text import parse_ports, guess_clock_reset, mask_comments_and_strings
from harness.verilog_text import resolve_params, eval_width

cat = yaml.safe_load(open(ROOT / "catalog.yaml"))
problems = []
MANUAL_RST = {
    "LIFObuffer": {"rst": "Rst", "rst_active_low": False},
}

for name, e in sorted(cat.items()):
    if not e.get("golden_file"):
        continue
    p = RTLLM / e["golden_file"]
    ports = parse_ports(p)
    ck = guess_clock_reset(p)

    src = mask_comments_and_strings(p.read_text())      # ← 新增
    e["modules"] = re.findall(r"\bmodule\s+(\w+)", src)  # ← 新增
    e["has_submodules"] = len(e["modules"]) > 1          # ← 新增

    e["ports"] = ports
    e["clk"] = ck["clk"]
    e["rst"] = ck["rst"]
    e["rst_active_low"] = ck["rst_active_low"]
    
    if name in MANUAL_RST:                     # ← 先覆寫
        e.update(MANUAL_RST[name])

    e["seq"] = ck["clk"] is not None          # 時序 vs 組合
    e["no_reset"] = (e["clk"] is not None and e["rst"] is None)

    if not ports:
        problems.append((name, "no ports parsed"))
    else:
        ins  = [x for x in ports if x["dir"] == "input"]
        outs = [x for x in ports if x["dir"] == "output"]
        if not outs:
            problems.append((name, "no outputs"))
        if not ins:
            problems.append((name, "no inputs"))

    print(f"{name:26s} {'SEQ' if e['seq'] else 'CMB'} "
          f"ports={len(ports) if ports else 0:2d} "
          f"clk={str(e['clk']):10s} rst={str(e['rst']):12s} "
          f"{'low' if e['rst_active_low'] else 'high'}")

print("\nproblems:", *problems, sep="\n  ")
with open(ROOT / "catalog.yaml", "w") as f:
    yaml.safe_dump(cat, f, sort_keys=True)
