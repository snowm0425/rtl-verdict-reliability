module alu (
    input  [31:0] a,
    input  [31:0] b,
    input  [5:0]  aluc,
    output [31:0] r,
    output        zero,
    output        carry,
    output        negative,
    output        overflow,
    output        flag
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

    reg [31:0] res;
    reg        carry_out;
    reg        overflow_out;
    reg        flag_out;

    // Signed versions of a and b for signed comparisons
    wire signed [31:0] a_signed = a;
    wire signed [31:0] b_signed = b;

    // Compute carry and overflow for add/sub operations
    // For addition: carry = carry out of bit 31, overflow = xor of carry into and out of bit 31
    // For subtraction: a - b = a + ~b + 1
    wire [32:0] add_result = a + b;
    wire [32:0] sub_result = a - b;

    // For ADD: carry = add_result[32], overflow = (a[31] & b[31] & ~add_result[31]) | (~a[31] & ~b[31] & add_result[31])
    // For SUB: carry = !a[31] | b[31] | !sub_result[31] (borrow), but typically carry in MIPS is borrow for sub
    // Actually, for SUB, carry out is typically defined as no borrow. Let's use standard definitions.
    // ADD: carry = add_result[32]
    // SUB: carry = !borrow, where borrow = a < b (unsigned). So carry = (a >= b) unsigned.
    //   borrow = !a[31] | b[31] | !sub_result[31]
    //   carry = !borrow = a[31] & !b[31] | sub_result[31] ... this is messy.
    // Let's compute carry and overflow properly.

    // ADD carry and overflow
    wire add_carry = add_result[32];
    wire add_overflow = (a[31] & b[31] & ~add_result[31]) | (~a[31] & ~b[31] & add_result[31]);

    // SUB: a - b. We can compute as a + (~b) + 1
    wire [32:0] sub_add_result = a + (~b) + 1;
    // Carry for SUB: in many MIPS implementations, carry is the borrow inverted.
    // Borrow = !a[31] | b[31] | !sub_result[31]
    // Let's define carry for SUB as no-borrow, i.e., carry = 1 if a >= b (unsigned)
    // borrow = !a[31] | b[31] | !sub_result[31]
    // So carry = !borrow = a[31] & !b[31] | sub_result[31] ... not quite.
    // Actually, borrow = !(a >= b). So carry = (a >= b).
    // Let's just compute: carry_sub = (a >= b) for unsigned.
    // But we can also use: carry_sub = !sub_add_result[32] ... wait, sub_add_result is a + ~b + 1.
    // The carry out of a + ~b + 1 is 1 if there's no borrow from a - b.
    // Because a - b = a + ~b + 1, and the carry out of this addition is the inverse of borrow.
    // So carry_sub = sub_add_result[32].
    wire sub_carry = sub_add_result[32];
    wire sub_overflow = (a[31] & ~b[31] & ~sub_result[31]) | (~a[31] & b[31] & sub_result[31]);

    always @(*) begin
        carry_out = 0;
        overflow_out = 0;
        flag_out = 0;
        res = 0;

        case (aluc)
            ADD: begin
                res = add_result[31:0];
                carry_out = add_carry;
                overflow_out = add_overflow;
            end
            ADDU: begin
                res = add_result[31:0];
                carry_out = add_carry;
                overflow_out = 0;
            end
            SUB: begin
                res = sub_result[31:0];
                carry_out = sub_carry;
                overflow_out = sub_overflow;
            end
            SUBU: begin
                res = sub_result[31:0];
                carry_out = sub_carry;
                overflow_out = 0;
            end
            AND: begin
                res = a & b;
                carry_out = 0;
                overflow_out = 0;
            end
            OR: begin
                res = a | b;
                carry_out = 0;
                overflow_out = 0;
            end
            XOR: begin
                res = a ^ b;
                carry_out = 0;
                overflow_out = 0;
            end
            NOR: begin
                res = ~(a | b);
                carry_out = 0;
                overflow_out = 0;
            end
            SLT: begin
                res = (a_signed < b_signed) ? 32'd1 : 32'd0;
                carry_out = 0;
                overflow_out = 0;
                flag_out = 1;
            end
            SLTU: begin
                res = (a < b) ? 32'd1 : 32'd0;
                carry_out = 0;
                overflow_out = 0;
                flag_out = 1;
            end
            SLL: begin
                // SLL: shift left by constant in b[4:0]
                res = b[4:0] == 0 ? a : (a << b[4:0]);
                carry_out = 0;
                overflow_out = 0;
            end
            SRL: begin
                // SRL: shift right logical by constant in b[4:0]
                res = b[4:0] == 0 ? a : (a >> b[4:0]);
                carry_out = 0;
                overflow_out = 0;
            end
            SRA: begin
                // SRA: shift right arithmetic by constant in b[4:0]
                if (b[4:0] == 0)
                    res = a;
                else
                    res = $signed(a) >>> b[4:0];
                carry_out = 0;
                overflow_out = 0;
            end
            SLLV: begin
                // SLLV: shift left by variable in b[4:0]
                res = b[4:0] == 0 ? a : (a << b[4:0]);
                carry_out = 0;
                overflow_out = 0;
            end
            SRLV: begin
                // SRLV: shift right logical by variable in b[4:0]
                res = b[4:0] == 0 ? a : (a >> b[4:0]);
                carry_out = 0;
                overflow_out = 0;
            end
            SRAV: begin
                // SRAV: shift right arithmetic by variable in b[4:0]
                if (b[4:0] == 0)
                    res = a;
                else
                    res = $signed(a) >>> b[4:0];
                carry_out = 0;
                overflow_out = 0;
            end
            LUI: begin
                // LUI: load upper immediate, result = a[31:16] << 16
                res = {a[15:0], 16'b0};
                carry_out = 0;
                overflow_out = 0;
            end
            default: begin
                res = 32'bz;
                carry_out = 0;
                overflow_out = 0;
                flag_out = 0;
            end
        endcase
    end

    assign r = res;
    assign zero = (res == 32'd0);
    assign carry = carry_out;
    assign negative = res[31];
    assign overflow = overflow_out;
    assign flag = flag_out;

endmodule