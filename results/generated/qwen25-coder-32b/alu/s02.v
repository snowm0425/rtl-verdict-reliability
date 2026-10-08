module alu (
    input [31:0] a,
    input [31:0] b,
    input [5:0] aluc,
    output [31:0] r,
    output zero,
    output carry,
    output negative,
    output overflow,
    output flag
);

    // Parameters for ALU control signals
    parameter ADD = 6'b100000;
    parameter ADDU = 6'b100001;
    parameter SUB = 6'b100010;
    parameter SUBU = 6'b100011;
    parameter AND = 6'b100100;
    parameter OR = 6'b100101;
    parameter XOR = 6'b100110;
    parameter NOR = 6'b100111;
    parameter SLT = 6'b101010;
    parameter SLTU = 6'b101011;
    parameter SLL = 6'b000000;
    parameter SRL = 6'b000010;
    parameter SRA = 6'b000011;
    parameter SLLV = 6'b000100;
    parameter SRLV = 6'b000110;
    parameter SRAV = 6'b000111;
    parameter LUI = 6'b001111;

    // Signed and unsigned versions of the operands
    wire [31:0] a_signed = a;
    wire [31:0] b_signed = b;
    wire [31:0] a_unsigned = a;
    wire [31:0] b_unsigned = b;

    // Result register
    reg [32:0] res;

    // Internal wires for flag, zero, carry, negative, overflow
    wire flag_int;
    wire zero_int;
    wire carry_int;
    wire negative_int;
    wire overflow_int;

    // Assign outputs
    assign r = res[31:0];
    assign zero = zero_int;
    assign carry = carry_int;
    assign negative = negative_int;
    assign overflow = overflow_int;
    assign flag = (aluc == SLT || aluc == SLTU) ? flag_int : 1'bz;

    // ALU operations
    always @(*) begin
        case (aluc)
            ADD: begin
                res = a_signed + b_signed;
                flag_int = 1'b0;
            end
            ADDU: begin
                res = a_unsigned + b_unsigned;
                flag_int = 1'b0;
            end
            SUB: begin
                res = a_signed - b_signed;
                flag_int = 1'b0;
            end
            SUBU: begin
                res = a_unsigned - b_unsigned;
                flag_int = 1'b0;
            end
            AND: begin
                res = a & b;
                flag_int = 1'b0;
            end
            OR: begin
                res = a | b;
                flag_int = 1'b0;
            end
            XOR: begin
                res = a ^ b;
                flag_int = 1'b0;
            end
            NOR: begin
                res = ~(a | b);
                flag_int = 1'b0;
            end
            SLT: begin
                res = (a_signed < b_signed) ? 32'b1 : 32'b0;
                flag_int = res[0];
            end
            SLTU: begin
                res = (a_unsigned < b_unsigned) ? 32'b1 : 32'b0;
                flag_int = res[0];
            end
            SLL: begin
                res = {32'b0, a[31:0]} << b[4:0];
                flag_int = 1'b0;
            end
            SRL: begin
                res = {32'b0, a[31:0]} >> b[4:0];
                flag_int = 1'b0;
            end
            SRA: begin
                res = {{32{a_signed[31]}}, a[31:0]} >>> b[4:0];
                flag_int = 1'b0;
            end
            SLLV: begin
                res = {32'b0, a[31:0]} << b[4:0];
                flag_int = 1'b0;
            end
            SRLV: begin
                res = {32'b0, a[31:0]} >> b[4:0];
                flag_int = 1'b0;
            end
            SRAV: begin
                res = {{32{a_signed[31]}}, a[31:0]} >>> b[4:0];
                flag_int = 1'b0;
            end
            LUI: begin
                res = {a[15:0], 16'b0};
                flag_int = 1'b0;
            end
            default: begin
                res = 33'bz;
                flag_int = 1'bz;
            end
        endcase
    end

    // Determine zero, carry, negative, and overflow
    assign zero_int = (res[31:0] == 32'b0);
    assign carry_int = (res[32]);
    assign negative_int = res[31];
    assign overflow_int = (aluc == ADD && a_signed[31] == b_signed[31] && a_signed[31] != res[31]) ||
                           (aluc == SUB && a_signed[31] != b_signed[31] && a_signed[31] != res[31]);
endmodule