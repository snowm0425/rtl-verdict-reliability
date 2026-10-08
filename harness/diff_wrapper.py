import random, re
from harness.verilog_text import (rename_module, resolve_params, eval_width, header_params)

# 規格定義的輸入域限制；{v} 會被 stim(...) 呼叫取代
# 港口名稱請對照 catalog.yaml 的 ports 欄位確認
INPUT_CONSTRAINTS = {
    "adder_bcd":   {"A": "({v}) % 10", "B": "({v}) % 10"},
    "RAM":         {"write_addr": "({v}) % 8", "read_addr": "({v}) % 8"},
}


def _decl(width, name):
    return f"{width} {name}".strip() if width else name

def build_wrapper(e, ref_src, dut_src, seed, cycles=2000):
    """產生 differential testbench：同時例化 ref 與 dut，逐 cycle 比對輸出。"""
    params = resolve_params(ref_src)                     # ← 新增：解析參數
    ref_hdr  = header_params(ref_src)           # 可覆寫的參數
    dut_hdr  = header_params(dut_src)
    shared   = [k for k in ref_hdr if k in dut_hdr]   # 兩邊都宣告的才能傳
    pspec    = ("#(" + ", ".join(f".{k}({ref_hdr[k]})" for k in shared) + ") ") \
               if shared else ""

    ports = e["ports"]
    ins  = [p for p in ports if p["dir"] == "input"]
    outs = [p for p in ports if p["dir"] == "output"]
    clk, rst = e["clk"], e["rst"]
    ctrl = {n for n in (clk, rst) if n}
    drive = [p for p in ins if p["name"] not in ctrl]
    cons  = INPUT_CONSTRAINTS.get(e.get("_name") or "", {})

    def W(p):                                            # ← 新增：解析後的位寬
        return eval_width(p["width"], params)

    # golden 全模組加前綴，避免與 candidate 的子模組撞名
    ref_top = e["golden_module"] or e["tb_expects"]
    for m in e.get("modules", []):
        ref_src = rename_module(ref_src, m, f"gtref_{m}")
    ref_top = f"gtref_{ref_top}"

    L = []
    L.append("`timescale 1ns/1ps")
    L.append(ref_src)
    L.append(dut_src)
    L.append("module diff_tb;")
    L.append("  integer errors = 0; integer checked = 0; integer i;")
    if clk: L.append(f"  reg {clk} = 0;")
    if rst: L.append(f"  reg {rst};")
    for p in drive:
        L.append(f"  reg {_decl(W(p), p['name'])};")
    for p in outs:
        L.append(f"  wire {_decl(W(p), p['name'] + '_ref')};")
        L.append(f"  wire {_decl(W(p), p['name'] + '_dut')};")

    def conn(suffix):
        c = []
        if clk: c.append(f".{clk}({clk})")
        if rst: c.append(f".{rst}({rst})")
        c += [f".{p['name']}({p['name']})" for p in drive]
        c += [f".{p['name']}({p['name']}_{suffix})" for p in outs]
        return ", ".join(c)

    L.append(f"  {ref_top} {pspec}u_ref ({conn('ref')});")
    L.append(f"  {e['tb_expects']} {pspec}u_dut ({conn('dut')});")

    if clk:
        L.append(f"  always #5 {clk} = ~{clk};")

    # 比對任務：只在 ref 不含 X 時比較
    L.append("  task check; begin")
    for p in outs:
        r, d = p["name"] + "_ref", p["name"] + "_dut"
        L.append(f"    if (^{r} !== 1'bx) begin checked = checked + 1;")
        L.append(f"      if ({r} !== {d}) begin errors = errors + 1;")
        L.append(f'        if (errors <= 5) $display("MISMATCH t=%0t {p["name"]} ref=%h dut=%h", $time, {r}, {d});')
        L.append("      end end")
    L.append("  end endtask")

    rnd = random.Random(seed)
    salts = {p["name"]: rnd.getrandbits(20) for p in drive}

    def assign(p, idx):
        v = f"stim({idx}, {salts[p['name']]})"
        if p["name"] in cons:
            v = cons[p["name"]].format(v=v)
        return f"      {p['name']} = {v};"

    L.append("  initial begin")
    #L.append("  integer rseed;")
    #L.append(f"    rseed = {rnd.getrandbits(31)};")
    #L.append(f"    $urandom(32'd{rnd.getrandbits(31)});")
    for p in drive:
        L.append(assign(p, 0).lstrip())
        #L.append(f"    {p['name']} = 0;")
    if rst:
        act = "0" if e["rst_active_low"] else "1"
        rel = "1" if e["rst_active_low"] else "0"
        L.append(f"    {rst} = {act}; #23; {rst} = {rel}; #2;")
    else:
        L.append("    #23;")

    n = cycles if clk else 512
    L.append(f"    for (i = 0; i < {n}; i = i + 1) begin")
    for p in drive:
        L.append(assign(p, "i"))
        #L.append(f"      {p['name']} = stim(i, {rnd.getrandbits(20)});")
    '''
    if clk:
        L.append(f"      @(negedge {clk}); #1; check;")
    else:
        L.append("      #5; check;")
    '''
    L.append(f"      @(negedge {clk}); #1; check;" if clk else "      #5; check;")
    L.append("    end")
    L.append('    if (errors == 0 && checked > 0) $display("DIFF_PASS checked=%0d", checked);')
    L.append('    else $display("DIFF_FAIL errors=%0d checked=%0d", errors, checked);')
    L.append("    $finish;")
    L.append("  end")

    # 激勵：60% 隨機 / 20% 邊界 / 20% 相鄰
    L.append("  function [63:0] stim(input integer idx, input integer salt);")
    L.append("    integer m; begin")
    L.append("      m = (idx + salt) % 10;")
    L.append("      if (m < 6)      stim = {$random, $random};")
    L.append("      else if (m < 8) stim = (m == 6) ? 64'd0 : {64{1'b1}};")
    L.append("      else            stim = {$random, $random} & 64'h3;")
    L.append("    end endfunction")
    L.append("endmodule")
    return "\n".join(L)

def diff_verdict(stdout):
    return "pass" if any(l.startswith("DIFF_PASS") for l in stdout.splitlines()) else "fail"
    #lines = stdout.splitlines()
    #if any(l.startswith("DIFF_PASS") for l in lines):
    #    return "pass"
    #return "fail"
