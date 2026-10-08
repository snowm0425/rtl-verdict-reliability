module alu (
    input  [31:0] a,        // First operand
    input  [31:0] b,        // Second operand
    input  [5:0]  aluc,       // ALU control signal
    output [31:0] r,        // Result of the operation
    output        zero,     // Zero flag
    output        carry,    // Carry flag
    output        negative, // Negative flag
    output        overflow, // Overflow flag
    output        flag      // SLT/SLTU flag
);

    // Parameters for ALU operations
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

    // Internal wires and registers
    reg  [32:0] res; // 33-bit result to capture carry for overflow detection
    wire [31:0] a_signed, b_signed;

    // Assign signed versions of the operands
    assign a_signed = a;
    assign b_signed = b;

    // Assign zero flag
    assign zero = (res[31:0] == 32'b0);

    // Assign negative flag
    assign negative = res[31];

    // Assign carry flag
    assign carry = res[32];

    // Assign overflow flag
    assign overflow = (aluc == ADD && a_signed[31] == b_signed[31] && a_signed[31] != res[31]) ||
                     (aluc == SUB && a_signed[31] != b_signed[31] && a_signed[31] != res[31]);

    // Assign flag for SLT and SLTU
    assign flag = (aluc == SLT) ? ($signed(a) < $signed(b)) :
                  (aluc == SLTU) ? (a < b) :
                  1'bz; // High-impedance if not SLT or SLTU

    // Main logic for ALU operations
    always @(*) begin
        case (aluc)
            ADD:  res = a_signed + b_signed;
            ADDU: res = a + b;
            SUB:  res = a_signed - b_signed;
            SUBU: res = a - b;
            AND:  res = a & b;
            OR:   res = a | b;
            XOR:  res = a ^ b;
            NOR:  res = ~(a | b);
            SLT:  res = ($signed(a) < $signed(b)) ? 32'b1 : 32'b0;
            SLTU: res = (a < b) ? 32'b1 : 32'b0;
            SLL:  res = {32'b0, a[31:5]}; // Logical left shift by a[4:0]
            SRL:  res = {a[31:31], a[31:5]}; // Logical right shift by a[4:0]
            SRA:  res = {{32{a[31]}}, a[31:5]}; // Arithmetic right shift by a[4:0]
            SLLV: res = a << b[4:0]; // Logical left shift by b[4:0]
            SRLV: res = a >> b[4:0]; // Logical right shift by b[4:0]
            SRAV: res = {{32{a[31]}}, a[31:5]} >> b[4:0]; // Arithmetic right shift by b[4:0]
            LUI:  res = {a[15:0], 16'b0}; // Load upper immediate
            default: res = 33'bZ; // High-impedance if undefined operation
        endcase
    end

endmodule