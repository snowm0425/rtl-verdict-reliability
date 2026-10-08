# harness/build_catalog.py
import json, hashlib, yaml
from pathlib import Path
from harness.config import GATETRUTH, RTLLM, ROOT

AUDIT = GATETRUTH / "external-audit/results/rtllm/final-g2012"

def sha256(p): return hashlib.sha256(p.read_bytes()).hexdigest()

cat = {}
for f in sorted(AUDIT.glob("*.json")):
    if f.name == "summary.json":
        continue
    d = json.load(open(f))
    name = d["task_id"]
    notes = d.get("notes", "")
    import re
    m = re.search(r"module alias (\w+) -> (\w+)", notes)
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

print(len(cat), "designs;",
      sum(v["alias_needed"] for v in cat.values()), "need alias;",
      sum(v["status"] == "audited" for v in cat.values()), "audited")
yaml.safe_dump(cat, open(ROOT / "catalog.yaml", "w"), sort_keys=True)
