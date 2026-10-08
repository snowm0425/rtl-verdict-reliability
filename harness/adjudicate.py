import yaml, subprocess, shutil, csv, random, re
from harness.config import RTLLM, ROOT, SCRATCH, IVERILOG, VVP, IV_FLAGS
from harness.diff_wrapper import build_wrapper

cat = yaml.safe_load(open(ROOT/"catalog.yaml"))
for _n, _e in cat.items():
    _e["_name"] = _n
GEN = ROOT/"results"/"generated"
rows = list(csv.DictReader(open(ROOT/"results"/"dual_verdicts.csv")))

# 兩類不一致
tb_pass_diff_fail = [r for r in rows if r["verdict_tb"]=="pass" and r["verdict_diff"]=="fail"]
tb_fail_diff_pass = [r for r in rows if r["verdict_tb"]=="fail" and r["verdict_diff"]=="pass"]
print(f"TB pass / DIFF fail: {len(tb_pass_diff_fail)}")
print(f"TB fail / DIFF pass: {len(tb_fail_diff_pass)}")

rnd = random.Random(20260824)
# 分層抽樣：每個設計最多取 1 個，確保涵蓋多個設計
def stratified(pool, k):
    by_design = {}
    for r in pool:
        by_design.setdefault(r["design"], []).append(r)
    picks = [rnd.choice(v) for v in by_design.values()]
    rnd.shuffle(picks)
    return picks[:k]

sample = [("TB_PASS_DIFF_FAIL", r) for r in stratified(tb_pass_diff_fail, 10)] + \
         [("TB_FAIL_DIFF_PASS", r) for r in stratified(tb_fail_diff_pass, 5)]

out = []
for kind, r in sample:
    name, tag, sid = r["design"], r["model"], r["sample"]
    e = cat[name]
    ref = (RTLLM/e["golden_file"]).read_text()
    cand = (GEN/tag/name/f"{sid}.v").read_text()

    # 重跑 differential，抓 mismatch 明細
    wd = SCRATCH/"adj"/f"{tag}_{name}_{sid}"
    if wd.exists(): shutil.rmtree(wd)
    wd.mkdir(parents=True)
    for p in (RTLLM/e["testbench"]).parent.iterdir():
        if p.is_file() and p.suffix.lower() not in (".v",".sv"):
            shutil.copy2(p, wd/p.name)
    (wd/"t.v").write_text(build_wrapper(e, ref, cand, seed=1))
    c = subprocess.run([str(IVERILOG),*IV_FLAGS,"-o","a.vvp","t.v"],
                       capture_output=True,text=True,cwd=wd)
    diff_out = ""
    if c.returncode:
        diff_out = "[differential COMPILE ERROR]\n" + c.stderr[:400]
    else:
        s = subprocess.run([str(VVP),"a.vvp"],capture_output=True,text=True,cwd=wd,timeout=90)
        diff_out = "\n".join(l for l in s.stdout.splitlines()
                             if "MISMATCH" in l or "DIFF_" in l)[:800]

    # 原 testbench 輸出
    wd2 = SCRATCH/"adj_tb"/f"{tag}_{name}_{sid}"
    if wd2.exists(): shutil.rmtree(wd2)
    wd2.mkdir(parents=True)
    for p in (RTLLM/e["testbench"]).parent.iterdir():
        if p.is_file() and p.suffix.lower() not in (".v",".sv"):
            shutil.copy2(p, wd2/p.name)
    (wd2/"cand.v").write_text(cand)
    c2 = subprocess.run([str(IVERILOG),*IV_FLAGS,"-o","a.vvp","cand.v",str(RTLLM/e["testbench"])],
                        capture_output=True,text=True,cwd=wd2)
    tb_out = "[TB COMPILE ERROR]\n"+c2.stderr[:400] if c2.returncode else \
             subprocess.run([str(VVP),"a.vvp"],capture_output=True,text=True,cwd=wd2,timeout=60).stdout[:600]

    out.append(f"""
{'='*78}
CASE {len(out)+1}  [{kind}]  {tag} / {name} / {sid}
kill_rate={e['kill_rate']}  seq={e['seq']}  ports={len(e['ports'])}
{'='*78}

--- SPEC (excerpt) ---
{(RTLLM/e['testbench']).parent.joinpath('design_description.txt').read_text()[:600]}

--- GOLDEN ---
{ref[:1200]}

--- CANDIDATE ---
{cand[:1200]}

--- ORIGINAL TESTBENCH OUTPUT ---
{tb_out}

--- DIFFERENTIAL OUTPUT ---
{diff_out}

--- VERDICT: which oracle is right?  [ ] differential  [ ] original TB  [ ] unclear
--- NOTE:
""")

(ROOT/"results"/"adjudication.txt").write_text("\n".join(out))
with open(ROOT/"results"/"adjudication_index.csv","w",newline="") as fh:
    w = csv.writer(fh); w.writerow(["case","kind","model","design","sample","kill_rate"])
    for i,(kind,r) in enumerate(sample,1):
        w.writerow([i,kind,r["model"],r["design"],r["sample"],cat[r["design"]]["kill_rate"]])

print(f"\nwrote {len(out)} cases -> results/adjudication.txt")
