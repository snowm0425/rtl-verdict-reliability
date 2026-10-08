import yaml, csv
from collections import defaultdict
from harness.config import ROOT

cat = yaml.safe_load(open(ROOT/"catalog.yaml"))
rows = list(csv.DictReader(open(ROOT/"results"/"dual_verdicts.csv")))
#EXCL = {"LIFObuffer"}
EXCL = {
    "LIFObuffer",              # EN-gated reset + memory array，初始狀態無法對齊
    "fixed_point_adder",       # 規格未指定定點數表示法（golden 用 sign-magnitude）
    "fixed_point_substractor", # 同上
    "RAM",                     # golden 宣告深度 12/寬度 8，與規格的 8/6 不符
}
models = sorted({r["model"] for r in rows})

def stats(rs):
    n = len(rs)
    tb = sum(r["verdict_tb"]=="pass" for r in rs)
    df = sum(r["verdict_diff"]=="pass" for r in rs)
    return n, tb, df

# ---- 總體 + RQ2 ranking ----
print("=== overall pass@1 by model ===")
rank_tb, rank_df = {}, {}
for m in models:
    rs = [r for r in rows if r["model"]==m and r["design"] not in EXCL]
    n, tb, df = stats(rs)
    rank_tb[m], rank_df[m] = tb/n, df/n
    print(f"  {m:22s} TB {tb:3d}/{n} ({100*tb/n:5.1f}%)   "
          f"DIFF {df:3d}/{n} ({100*df/n:5.1f}%)   inflation {100*(tb-df)/n:+5.1f} pp")

print("\n=== RQ2: ranking ===")
o_tb = sorted(models, key=lambda m: -rank_tb[m])
o_df = sorted(models, key=lambda m: -rank_df[m])
print("  by original TB :", " > ".join(o_tb))
print("  by differential:", " > ".join(o_df))
print("  ranking changed:", o_tb != o_df)

# ---- RQ1: 每題 inflation vs kill_rate（合併模型）----
print("\n=== RQ1 ===")
pairs = []
for name in sorted(cat):
    e = cat[name]
    if e["status"]!="audited" or name in EXCL: continue
    rs = [r for r in rows if r["design"]==name]
    n, tb, df = stats(rs)
    if not n: continue
    pairs.append((e["kill_rate"], (tb-df)/n, name, tb, df, n))

for kr, infl, name, tb, df, n in sorted(pairs):
    if infl != 0:
        print(f"  {name:26s} kill={kr:5.1f}  tb={tb}/{n} diff={df}/{n}  infl={infl:+.2f}")

try:
    from scipy.stats import spearmanr
    rho, p = spearmanr([x[0] for x in pairs], [x[1] for x in pairs])
    print(f"\n  Spearman(kill_rate, inflation): rho={rho:.3f} p={p:.4f}  (n={len(pairs)})")
    # 控制設計規模的偏相關
    sizes = [cat[x[2]]["mutants"] for x in pairs]
    r_ks, _ = spearmanr([x[0] for x in pairs], sizes)
    r_is, _ = spearmanr([x[1] for x in pairs], sizes)
    import math
    denom = math.sqrt((1-r_ks**2)*(1-r_is**2))
    print(f"  partial rho (control mutant-count): {(rho - r_ks*r_is)/denom:.3f}")
except ImportError:
    print("  (pip install scipy)")

# ---- RQ3: 依 GateTruth operator 分布 ----
print("\n=== RQ3: inflation by dominant operator ===")
by_op = defaultdict(lambda: [0,0,0])
for kr, infl, name, tb, df, n in pairs:
    ops = cat[name].get("operator_counts") or {}
    if not ops: continue
    dom = max(ops, key=ops.get)
    by_op[dom][0] += tb; by_op[dom][1] += df; by_op[dom][2] += n
for op,(tb,df,n) in sorted(by_op.items(), key=lambda x: -(x[1][0]-x[1][1])/max(x[1][2],1)):
    print(f"  {op:28s} tb={tb:3d}/{n:3d} diff={df:3d}/{n:3d}  infl={100*(tb-df)/n:+5.1f} pp")
