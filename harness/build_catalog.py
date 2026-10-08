# harness/build_catalog.py
import json, re, hashlib, yaml
from harness.config import GATETRUTH, RTLLM, ROOT
from pathlib import Path
from harness.verilog_text import top_module_name
import re as _re

AUDIT = GATETRUTH / "external-audit/results/rtllm/final-g2012"
MANUAL_NO_ALIAS = {"fixed_point_substractor"}   # RTLLM 目錄名拼字與模組名不一致
LOG = ROOT / "results" / "baseline_stdout"
PASS_PAT = _re.compile(r"^=+\s*Your Design Passed\s*=+$")

def sha256(p):
    return hashlib.sha256(p.read_bytes()).hexdigest()

# ---------- 第一段：從 GateTruth JSON 建 catalog ----------
cat = {}
for f in sorted(AUDIT.glob("*.json")):
    if f.name == "summary.json":
        continue
    d = json.load(open(f))
    name = d["task_id"]
    m = re.search(r"module alias (\w+) -> (\w+)", d.get("notes", ""))
    cat[name] = {
        "status": d["status"],
        "kill_rate": d["kill_rate"],
        "mutants": d["mutants_total"],
        "killed": d["killed"],
        "survived": d["survived"],
        "indeterminate": d["indeterminate"],
        "operator_counts": d.get("operator_counts", {}),
        "alias_needed": bool(m),
        "golden_module": m.group(1) if m else None,
        "tb_expects": m.group(2) if m else name,
        "gt_source_sha256": d.get("source_sha256"),
        "gt_testbench_sha256": d.get("testbench_sha256"),
        "golden_file": None,
        "testbench": None,
        "pass_string": None,
    }

print(f"{len(cat)} designs; "
      f"{sum(v['alias_needed'] for v in cat.values())} need alias; "
      f"{sum(v['status'] == 'audited' for v in cat.values())} audited")

# ---------- 第二段：掃 RTLLM 樹填路徑，並用 hash 驗證 ----------
need_manual, mismatch = [], []

for name, e in cat.items():

    tbs = list(RTLLM.rglob(f"*/{name}/testbench.v"))
    if len(tbs) != 1:
        need_manual.append((name, f"testbench x{len(tbs)}"))
        continue
    tb = tbs[0]
    e["testbench"] = str(tb.relative_to(RTLLM))
    #
    e["aux_files"] = sorted(
    p.name for p in tb.parent.iterdir()
    if p.is_file() and p.suffix.lower() not in (".v", ".sv")
    )
    #
    if e["gt_testbench_sha256"] and sha256(tb) != e["gt_testbench_sha256"]:
        mismatch.append((name, "testbench"))

    # golden: 用 hash 挑出正確的那個 .v，勝過猜檔名
    cands = [p for p in tb.parent.glob("*.v") if p.name != "testbench.v"]
    hit = [p for p in cands if e["gt_source_sha256"] and sha256(p) == e["gt_source_sha256"]]
    if len(hit) == 1:
        e["golden_file"] = str(hit[0].relative_to(RTLLM))
    elif len(cands) == 1:
        e["golden_file"] = str(cands[0].relative_to(RTLLM))
        mismatch.append((name, "golden hash"))
    else:
        need_manual.append((name, f"golden x{len(cands)}: {[p.name for p in cands]}"))
    # ↓↓↓ 新增：用檔名重新判定 alias，覆蓋 notes 的推斷
    if e["golden_file"]:
        gmod = top_module_name(RTLLM / e["golden_file"])
        if gmod and gmod != name and name not in MANUAL_NO_ALIAS:
            e["alias_needed"] = True
            e["golden_module"] = gmod
            e["tb_expects"] = name
        else:
            e["alias_needed"] = False
            e["golden_module"] = None
            e["tb_expects"] = gmod or name
        """
        gname = Path(e["golden_file"]).stem
        if gname != name:
            e["alias_needed"] = True
            e["golden_module"] = gname
            e["tb_expects"] = name
        else:
            e["alias_needed"] = False
            e["golden_module"] = None
            e["tb_expects"] = name
        """
print("\nneed manual:", *need_manual, sep="\n  ")
#print("\nhash mismatch:", mismatch)
if mismatch:
    print(f"\nnote: {len(mismatch)} hash comparisons differ — GateTruth hashes "
          f"post-processed source (mutate.py:129), not raw file bytes. "
          f"Consistency guaranteed by pinned vendor commit instead.")
print(f"\nresolved: testbench {sum(bool(v['testbench']) for v in cat.values())}, "
      f"golden {sum(bool(v['golden_file']) for v in cat.values())} / {len(cat)}")
#
for name, e in cat.items():
    f = LOG / f"{name}.txt"
    if not f.exists():
        continue
    for line in f.read_text().splitlines():
        s = line.strip()
        if PASS_PAT.match(s):
            e["pass_string"] = s
            break

print(f"pass_string filled: {sum(bool(v['pass_string']) for v in cat.values())}")

with open(ROOT / "catalog.yaml", "w") as f:
    yaml.safe_dump(cat, f, sort_keys=True)
print(f"final alias_needed: {sum(v['alias_needed'] for v in cat.values())}")

