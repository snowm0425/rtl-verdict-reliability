module alu (
    input  wire [31:0] a,
    input  wire [31:0] b,
    input  wire [5:0]  aluc,
    output reg  [31:0] r,
    output wire        zero,
    output wire        carry,
    output wire        negative,
    output wire        overflow,
    output wire        flag
);

    parameter ADD  = 6'b100000;
    parameter ADDU = 6'b100001;
    parameter SUB  = 6'b100010;
    parameter SUBU = 6'b100011;
    parameter AND  = 6'b100100;
    parameter OR   = 6'b100101;
    parameter XOR  = 6'b100110;
    parameter NOR  = 6'b100111;
    parameter SLT  = 6'b101010;
    parameter SLTU = 6'b101011;
    parameter SLL  = 6'b000000;
    parameter SRL  = 6'b000010;
    parameter SRA  = 6'b000011;
    parameter SLLV = 6'b000100;
    parameter SRLV = 6'b000110;
    parameter SRAV = 6'b000111;
    parameter LUI  = 6'b001111;

    // Internal signals
    wire [31:0] result;
    wire [32:0] add_result; // 33 bits to capture carry
    wire [32:0] sub_result; // 33 bits to capture borrow/carry
    wire [31:0] sll_result;
    wire [31:0] srl_result;
    wire [31:0] sra_result;
    wire [31:0] sllv_result;
    wire [31:0] srlv_result;
    wire [31:0] sraw_result;
    wire [31:0] lui_result;

    // Signed versions for SLT
    signed [31:0] a_signed;
    signed [31:0] b_signed;

    assign a_signed = $signed(a);
    assign b_signed = $signed(b);

    // Arithmetic operations
    assign add_result = {1'b0, a} + {1'b0, b};
    assign sub_result = {1'b0, a} - {1'b0, b};

    // Overflow detection for ADD
    wire add_overflow = (a[31] == b[31]) && (a[31] != add_result[31]);

    // Overflow detection for SUB
    // Overflow if a and b have different signs, and result has different sign than a
    wire sub_overflow = (a[31] != b[31]) && (a[31] != sub_result[31]);

    // Carry for ADD: bit 32 of add_result
    wire add_carry = add_result[32];

    // Carry for SUB: In two's complement subtraction, carry out from MSB.
    // For MIPS, SUB/SUBU typically don't use carry in the same way, but let's define it consistently.
    // If we think of SUB as a + (~b + 1), the carry out of the 32-bit addition is the borrow.
    // Let's compute a + (~b) + 1 in 33 bits.
    wire [32:0] sub_add_result = {1'b0, a} + {1'b0, ~b} + 33'd1;
    wire sub_carry = sub_add_result[32]; // This is 1 if no borrow, 0 if borrow. 
    // Actually, for ALU carry flag, it's often defined as the carry out of the MSB.
    // Let's keep it simple: carry = bit 32 of the 33-bit result for both ADD and SUB operations.
    // But note: for SUB, the "carry" is actually the NOT borrow. In MIPS, SUBU doesn't use carry, 
    // but SUB can. Let's define carry as the carry-out from the 32-bit operation.
    // For ADD: carry = add_result[32]
    // For SUB: carry = sub_add_result[32] (which is 1 if a >= b in unsigned)

    // Logical operations
    assign result = aluc == ADD  ? add_result[31:0] :
                    aluc == ADDU ? add_result[31:0] :
                    aluc == SUB  ? sub_result[31:0] :
                    aluc == SUBU ? sub_result[31:0] :
                    aluc == AND  ? (a & b) :
                    aluc == OR   ? (a | b) :
                    aluc == XOR  ? (a ^ b) :
                    aluc == NOR  ? ~(a | b) :
                    aluc == SLT  ? ((a_signed < b_signed) ? 32'd1 : 32'd0) :
                    aluc == SLTU ? ((a < b) ? 32'd1 : 32'd0) :
                    aluc == SLL  ? (b << a[4:0]) :
                    aluc == SRL  ? (b >> a[4:0]) :
                    aluc == SRA  ? ($signed(b) >>> a[4:0]) :
                    aluc == SLLV ? (b << a[4:0]) :
                    aluc == SRLV ? (b >> a[4:0]) :
                    aluc == SRAV ? ($signed(b) >>> a[4:0]) :
                    aluc == LUI  ? {a[15:0], 16'b0} :
                    32'd0;

    // Wait, the specification says:
    // SLL, SRL, SRA use 'a' as shift amount? Let me re-read.
    // "For shift operations (SLL, SRL, SRA, SLLV, SRLV, SRAV), the shift amount is determined by the value of 'a' or 'a[4:0]'."
    // In MIPS:
    // SLL rt, rs, shamt: shamt is in the instruction, not a register. So 'a' here would be shamt[4:0]?
    // SLLV rt, rs, ra: shift amount is ra[4:0]. So 'b' is the data, 'a' is the shift amount.
    // Let me re-read the spec: "the 'a' and 'b' are the two operands of the ALU"
    // For SLL: typically, the operand to shift is in one register, and the shift amount is in the instruction.
    // But the problem says: "the shift amount is determined by the value of 'a' or 'a[4:0]'"
    // And "For the LUI operation, the upper 16 bits of 'a' are concatenated with 16 zeros"
    // This suggests that for shifts, 'a' contains the shift amount, and 'b' contains the data to shift.
    // Let me re-examine:
    // SLL: shift left logical. In MIPS, SLL rt, rs, shamt. The data is rs, shift is shamt.
    // If 'a' is the shift amount and 'b' is the data, then SLL = b << a[4:0].
    // SLLV: shift left logical variable. In MIPS, SLLV rt, rs, ra. Data is rs, shift is ra[4:0].
    // So if 'a' is the shift amount and 'b' is the data, SLLV = b << a[4:0].
    // This seems consistent. So 'a' is the shift amount, 'b' is the data.

    // Let me redo the result assignment with this understanding.
    // Actually, looking at typical ALU designs for MIPS:
    // For arithmetic/logic: a and b are operands.
    // For shifts: one operand is the data, the other is the shift amount.
    // The spec says "the shift amount is determined by the value of 'a'", so 'a' is the shift amount, 'b' is the data.

    // Let me rewrite the result assignment:
    wire [31:0] result_wire = aluc == ADD  ? add_result[31:0] :
                    aluc == ADDU ? add_result[31:0] :
                    aluc == SUB  ? sub_result[31:0] :
                    aluc == SUBU ? sub_result[31:0] :
                    aluc == AND  ? (a & b) :
                    aluc == OR   ? (a | b) :
                    aluc == XOR  ? (a ^ b) :
                    aluc == NOR  ? ~(a | b) :
                    aluc == SLT  ? ((a_signed < b_signed) ? 32'd1 : 32'd0) :
                    aluc == SLTU ? ((a < b) ? 32'd1 : 32'd0) :
                    aluc == SLL  ? (b << a[4:0]) :
                    aluc == SRL  ? (b >> a[4:0]) :
                    aluc == SRA  ? ($signed(b) >>> a[4:0]) :
                    aluc == SLLV ? (b << a[4:0]) :
                    aluc == SRLV ? (b >> a[4:0]) :
                    aluc == SRAV ? ($signed(b) >>> a[4:0]) :
                    aluc == LUI  ? {a[15:0], 16'b0} :
                    32'd0;

    // Wait, for SLT and SLTU, 'a' and 'b' are the operands to compare. That's fine.
    // For shifts, 'a' is the shift amount, 'b' is the data. That's fine.
    // For LUI, 'a' contains the immediate value in the upper 16 bits? 
    // "the upper 16 bits of 'a' are concatenated with 16 zeros"
    // So LUI result = {a[15:0], 16'b0}. This means 'a' has the immediate in bits [15:0], 
    // and we place it in the upper 16 bits of the result. Wait, that would be a[15:0] in bits [31:16].
    // Yes, {a[15:0], 16'b0} puts a[15:0] in bits 31:16 and 0 in bits 15:0. Correct.

    assign r = result_wire;

    // Flags
    assign zero = (r == 32'd0);
    assign negative = r[31];
    
    // Carry: only meaningful for ADD/ADDU/SUB/SUBU
    assign carry = (aluc == ADD || aluc == ADDU) ? add_carry :
                   (aluc == SUB || aluc == SUBU) ? sub_carry :
                   1'b0;

    // Overflow: only meaningful for ADD/SUB (signed)
    assign overflow = (aluc == ADD) ? add_overflow :
                      (aluc == SUB) ? sub_overflow :
                      1'b0;

    // Flag: set for SLT and SLTU
    assign flag = (aluc == SLT || aluc == SLTU) ? r[0] : 1'b0;

endmodule