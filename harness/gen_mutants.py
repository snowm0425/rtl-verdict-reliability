# harness/gen_mutants.py
import yaml, json
from harness.config import RTLLM, ROOT
from harness.gt_mutators import generate_mutants

OUT = ROOT / "results" / "mutants"
cat = yaml.safe_load(open(ROOT / "catalog.yaml"))
AUDIT = ROOT.parent  # 不需要，直接用 GateTruth 路徑
from harness.config import GATETRUTH
GT = GATETRUTH / "external-audit/results/rtllm/final-g2012"

total = 0
for name, e in sorted(cat.items()):
    if e["status"] != "audited":
        continue
    src = (RTLLM / e["golden_file"]).read_text()
    muts = generate_mutants(f"rtllm_{name}", src, include_task_specs=False)

    d = OUT / name
    d.mkdir(parents=True, exist_ok=True)
    for m in muts:
        (d / f"{m.id}.v").write_text(m.source)

    # 對照 GateTruth 的紀錄
    gt = json.load(open(GT / f"{name}.json"))
    ids_mine = {m.id for m in muts}
    ids_gt   = {p["id"] for p in gt["per_mutant"]}
    flag = "OK " if ids_mine == ids_gt else "DIFF"
    print(f"{flag} {name:26s} mine={len(muts):4d} gt={gt['mutants_total']:4d}")
    total += len(muts)

print("total:", total, "(expect 775)")
