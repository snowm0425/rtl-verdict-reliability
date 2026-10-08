import yaml, re, requests
from harness.config import RTLLM, ROOT

cat = yaml.safe_load(open(ROOT/"catalog.yaml"))
OUT = ROOT/"results"/"generated"; OUT.mkdir(parents=True, exist_ok=True)
API = "http://localhost:8000/v1/chat/completions"
MODEL = "Qwen/Qwen2.5-Coder-32B-Instruct-AWQ"
K = 10

def extract_module(text):
    #text = re.sub(r"^```\w*\n?", "", text, flags=re.M)
    #text = re.sub(r"```", "", text)
    #return text.strip()
    # 1. 優先抓 ```verilog ... ``` 或 ``` ... ``` 區塊，取最長的一段
    blocks = re.findall(r"```(?:verilog|systemverilog|v|sv)?\s*\n(.*?)```", text, re.S | re.I)
    if blocks:
        code = max(blocks, key=len)
    else:
        code = text
    # 2. 只保留從第一個 module 到最後一個 endmodule 之間（去頭去尾的散文）
    #m = re.search(r"\bmodule\s+\w+.*\bendmodule\b", code, re.S)
    m = re.search(r"\bmodule\s+\w+.*\bendmodule\b", code, re.S)
    if m:
        code = m.group(0)
    return code.strip()

def prompt_for(e):
    d = (RTLLM/e["testbench"]).parent
    spec = d/"design_description.txt"
    return spec.read_text() if spec.exists() else ""
    #text = spec.read_text() if spec.exists() else ""
    #return (f"{text}\n\nWrite a synthesizable Verilog module named "
    #        f"{e['tb_expects']}. Output only Verilog code, no explanation.")

if __name__ == "__main__":
    for name in sorted(cat):
        e = cat[name]
        if e["status"] != "audited":
            continue
        d = OUT/name; d.mkdir(exist_ok=True)
        for k in range(K):
            r = requests.post(API, json={
                "model": MODEL, "max_tokens": 16384,
                "temperature": 0.8, "top_p": 0.95, "top_k": -1, "repetition_penalty": 1.0,
                "messages": [{"role":"user","content": prompt_for(e)}],
            }).json()
            raw = r["choices"][0]["message"]["content"]
            (d/f"s{k:02d}_raw.txt").write_text(raw)
            (d/f"s{k:02d}.v").write_text(extract_module(raw))
        print(f"{name}: {K} samples")
