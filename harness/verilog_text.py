import re
import ast

def mask_comments_and_strings(text: str) -> str:
    """回傳等長字串，註解與字串內容換成空白，供安全比對位置用。"""
    out = list(text)
    i, n = 0, len(text)
    while i < n:
        two = text[i:i+2]
        if two == "//":
            j = text.find("\n", i)
            j = n if j == -1 else j
        elif two == "/*":
            j = text.find("*/", i+2)
            j = n if j == -1 else j+2
        elif text[i] == '"':
            j = i+1
            while j < n and not (text[j] == '"' and text[j-1] != "\\"):
                j += 1
            j = min(j+1, n)
        else:
            i += 1
            continue
        for k in range(i, j):
            if out[k] != "\n":
                out[k] = " "
        i = j
    return "".join(out)


def rename_module(text: str, old: str, new: str) -> str:
    """只在程式碼區（非註解/字串）替換識別字 old -> new。"""
    masked = mask_comments_and_strings(text)
    spans = [m.span() for m in re.finditer(rf"\b{re.escape(old)}\b", masked)]
    for s, e in reversed(spans):          # 從後往前，避免位移
        text = text[:s] + new + text[e:]
    return text


def alias_golden(src, from_mod: str, to_mod: str, workdir):
    """把 golden 複製到 workdir 並改名；vendor 檔永不修改。回傳新路徑。"""
    workdir.mkdir(parents=True, exist_ok=True)
    dst = workdir / src.name
    dst.write_text(rename_module(src.read_text(), from_mod, to_mod))
    return dst

def top_module_name(path):
    """讀出檔案裡第一個 module 宣告的名稱（忽略註解與字串）。"""
    masked = mask_comments_and_strings(path.read_text())
    m = re.search(r"\bmodule\s+(\w+)", masked)
    return m.group(1) if m else None

def parse_ports(path):
    """從 module 宣告抽 port 方向、位寬、名稱。回傳 list of dict，失敗回 None。

    只處理 ANSI 風格（方向寫在 port list 裡）。non-ANSI 會回傳空 list。
    """
    src = mask_comments_and_strings(path.read_text())
    m = re.search(r"\bmodule\s+\w+\s*(#\s*\([^)]*\))?\s*\((.*?)\)\s*;", src, re.S)
    if not m:
        return None
    body = m.group(2)

    ports, cur_dir, cur_w = [], None, ""
    # 以逗號切，但不切位寬 [7:0] 裡的逗號
    for item in re.split(r",(?![^\[]*\])", body):
        item = item.strip()
        if not item:
            continue
        d = re.match(r"(input|output|inout)\b\s*", item)
        if d:
            cur_dir = d.group(1)
            cur_w = ""
            item = item[d.end():].strip()
        item = re.sub(r"^(wire|reg|logic|signed)\b\s*", "", item).strip()
        item = re.sub(r"^(wire|reg|logic|signed)\b\s*", "", item).strip()  # 可能兩層
        w = re.match(r"(\[[^\]]+\])\s*", item)
        if w:
            cur_w = w.group(1)
            item = item[w.end():].strip()
        nm = re.match(r"(\w+)", item)
        if nm and cur_dir:
            ports.append({"dir": cur_dir, "width": cur_w, "name": nm.group(1)})
    if not ports:
        # non-ANSI: port list 只有名字，方向宣告在 module body
        names = [n.strip() for n in re.split(r",", body) if n.strip()]
        decls = {}
        for m2 in re.finditer(
            r"\b(input|output|inout)\b\s*(?:wire|reg|logic|signed\s*)*\s*"
            r"(\[[^\]]+\])?\s*([\w\s,]+?)\s*;", src):
            d, w = m2.group(1), m2.group(2) or ""
            for nm in m2.group(3).split(","):
                nm = nm.strip()
                if nm:
                    decls[nm] = {"dir": d, "width": w, "name": nm}
        ports = [decls[n] for n in names if n in decls]

    return ports


def guess_clock_reset(path):
    """猜 clock 與 reset 訊號名稱及 reset 極性。結果需人工複核。"""
    src = mask_comments_and_strings(path.read_text())

    edges = re.findall(r"\b(pos|neg)edge\s+(\w+)", src)
    rst_name = next((n for _, n in edges if re.search(r"rst|reset", n, re.I)), None)
    clk_name = next((n for _, n in edges if not re.search(r"rst|reset", n, re.I)), None)

    # reset 若不在 sensitivity list（同步 reset），從 if 條件找
    if rst_name is None:
        m = re.search(r"if\s*\(\s*[!~]?\s*(\w*(?:rst|reset)\w*)\s*\)", src, re.I)
        rst_name = m.group(1) if m else None

    active_low = False
    if rst_name:
        active_low = (
            any(e == "neg" and n == rst_name for e, n in edges)
            or bool(re.search(rf"if\s*\(\s*[!~]\s*{re.escape(rst_name)}\b", src))
            or bool(re.search(r"_n\b|_b\b", rst_name))
        )

    return {"clk": clk_name, "rst": rst_name, "rst_active_low": active_low}
def resolve_params(src_text):
    """ 抓 module 的 parameter/localparam 預設值（含 #(...) 與 body 內宣告）。"""

    src = mask_comments_and_strings(src_text)
    params = {}
    for m in re.finditer(
        r"\b(?:parameter|localparam)\s+(?:integer\s+|\[[^\]]*\]\s*)?"
        r"(\w+)\s*=\s*([^,;)\n]+)", src):
        params[m.group(1)] = m.group(2).strip()

    return params

def eval_width(width_str, params):
    """把 [N-1:0] 這種含 parameter 的位寬，用 params 代入算成 [63:0]。"""
    if not width_str:
        return ""
    expr = width_str.strip().lstrip("[").rstrip("]")
    if ":" not in expr:
        return width_str
    # 反覆代入 parameter（可能有巢狀，如 N = 2*size）
    for _ in range(6):
        before = expr
        for k, v in params.items():
            expr = re.sub(rf"\b{re.escape(k)}\b", f"({v})", expr)
        if expr == before:
            break
    hi, lo = expr.split(":", 1)
    def _ev(s):
        return int(eval(compile(ast.parse(s.strip(), mode="eval"), "<w>", "eval"), {}, {}))
    try:
        return f"[{_ev(hi)}:{_ev(lo)}]"
    except Exception:
        return width_str

def header_params(src_text):
    """抽 module 宣告 #(...) 內的參數名與預設值（可被例化覆寫的那些）。"""
    src = mask_comments_and_strings(src_text)
    m = re.search(r"\bmodule\s+\w+\s*#\s*\(", src)
    if not m:
        return {}
    i, depth = m.end(), 1
    while i < len(src) and depth:
        if src[i] == "(": depth += 1
        elif src[i] == ")": depth -= 1
        i += 1
    body = src[m.end():i-1]

    # 以 depth-0 的逗號切開
    parts, buf, d = [], "", 0
    for ch in body:
        if ch in "([{": d += 1
        elif ch in ")]}": d -= 1
        if ch == "," and d == 0:
            parts.append(buf); buf = ""
        else:
            buf += ch
    parts.append(buf)

    out = {}
    for p in parts:
        p = re.sub(r"^\s*(parameter|localparam)\b", "", p).strip()
        p = re.sub(r"^(integer|int|realtime|time|real)\b", "", p).strip()
        p = re.sub(r"^\[[^\]]*\]", "", p).strip()
        mm = re.match(r"(\w+)\s*=\s*(.+)$", p, re.S)
        if mm:
            out[mm.group(1)] = mm.group(2).strip()
    return out
