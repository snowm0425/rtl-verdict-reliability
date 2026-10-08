module alu (
    input  [31:0] a,    // First operand
    input  [31:0] b,    // Second operand
    input  [5:0]  aluc,   // ALU control signal
    output [31:0] r,    // Result
    output        zero, // Zero flag
    output        carry, // Carry flag
    output        negative, // Negative flag
    output        overflow, // Overflow flag
    output        flag  // SLT or SLTU flag
);

    // Parameters for ALU operations
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

    // Internal wires
    wire [32:0] res; // 33-bit result to capture carry
    wire [31:0] res32; // 32-bit result
    wire [31:0] a_signed = { {32{a[31]}}, a }; // Sign-extend a for signed operations
    wire [31:0] b_signed = { {32{b[31]}}, b }; // Sign-extend b for signed operations

    // Assign flag output based on aluc
    assign flag = (aluc == SLT) ? (a_signed < b_signed) :
                 (aluc == SLTU) ? (a < b) :
                 1'bz;

    // Assign zero flag
    assign zero = (res32 == 32'b0) ? 1'b1 : 1'b0;

    // Assign carry flag
    assign carry = res[32];

    // Assign negative flag
    assign negative = res32[31];

    // Assign overflow flag
    assign overflow = (aluc == ADD) ? (a_signed[31] == b_signed[31]) && (a_signed[31] != res32[31]) :
                    (aluc == ADDU) ? 1'b0 :
                    (aluc == SUB) ? (a_signed[31] != b_signed[31]) && (a_signed[31] != res32[31]) :
                    (aluc == SUBU) ? 1'b0 :
                    1'bz;

    // Main logic
    always @(*) begin
        case (aluc)
            ADD:  res = a_signed + b_signed; // Signed addition
            ADDU: res = a + b; // Unsigned addition
            SUB:  res = a_signed - b_signed; // Signed subtraction
            SUBU: res = a - b; // Unsigned subtraction
            AND:  res = a & b;
            OR:   res = a | b;
            XOR:  res = a ^ b;
            NOR:  res = ~(a | b);
            SLT:  res = (a_signed < b_signed) ? 1 : 0;
            SLTU: res = (a < b) ? 1 : 0;
            SLL:  res = { b[31:27], a[26:0], 5'b0 }; // Shift Left Logical
            SRL:  res = { 5'b0, a[31:5] }; // Shift Right Logical
            SRA:  res = { {5{a[31]}}, a[31:5] }; // Shift Right Arithmetic
            SLLV: res = a << b[4:0]; // Variable Shift Left Logical
            SRLV: res = a >> b[4:0]; // Variable Shift Right Logical
            SRAV: res = {{32{a[31]}} & {32{b[4:0] >= 32}}, a} >> b[4:0]; // Variable Shift Right Arithmetic
            LUI:  res = { a[15:0], 16'b0 }; // Load Upper Immediate
            default: res = 33'bz;
        endcase
    end

    // Assign the lower 32 bits of res to r
    assign r = res32 = res[31:0];

endmodule