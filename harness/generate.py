import yaml, re, requests, sys
from harness.config import RTLLM, ROOT

cat = yaml.safe_load(open(ROOT/"catalog.yaml"))
API = "http://localhost:8000/v1/chat/completions"

MODELS = {
    "qwen25-coder-32b": {"id": "Qwen/Qwen2.5-Coder-32B-Instruct-AWQ", "extra": {}},
    "qwen38-27b":       {"id": "Qwen/Qwen3.8-27B",
                         "extra": {"chat_template_kwargs": {"enable_thinking": False}}},
    "qwen25-coder-7b":  {"id": "Qwen/Qwen2.5-Coder-7B-Instruct", "extra": {}},
}

def extract_module(text):
    blocks = re.findall(r"```(?:verilog|systemverilog|v|sv)?\s*\n(.*?)```", text, re.S | re.I)
    code = max(blocks, key=len) if blocks else text
    m = re.search(r"\bmodule\s+\w+.*\bendmodule\b", code, re.S)
    return (m.group(0) if m else code).strip()

def prompt_for(e):
    spec = (RTLLM/e["testbench"]).parent/"design_description.txt"
    return spec.read_text() if spec.exists() else ""

def run(tag, K):
    cfg = MODELS[tag]
    out = ROOT/"results"/"generated"/tag
    for name in sorted(cat):
        e = cat[name]
        if e["status"] != "audited":
            continue
        d = out/name; d.mkdir(parents=True, exist_ok=True)
        for k in range(K):
            f = d/f"s{k:02d}.v"
            if f.exists():          # 可續跑
                continue
            body = {"model": cfg["id"], "max_tokens": 16384,
                    "temperature": 0.8, "top_p": 0.95, "top_k": -1,
                    "repetition_penalty": 1.0,
                    "messages": [{"role": "user", "content": prompt_for(e)}]}
            body.update(cfg["extra"])
            r = requests.post(API, json=body, timeout=600).json()
            raw = r["choices"][0]["message"]["content"]
            (d/f"s{k:02d}_raw.txt").write_text(raw)
            f.write_text(extract_module(raw))
        print(f"{tag}/{name}: {K} samples", flush=True)

if __name__ == "__main__":
    tag = sys.argv[1]
    K = int(sys.argv[2]) if len(sys.argv) > 2 else 5
    run(tag, K)
