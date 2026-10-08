module alu (
    input [31:0] a,
    input [31:0] b,
    input [5:0] aluc,
    output reg [31:0] r,
    output reg zero,
    output reg carry,
    output reg negative,
    output reg overflow,
    output reg flag
);

    // Define parameters for ALU operations
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

    // Intermediate result wire
    reg [32:0] res; // 33 bits to capture carry

    // Default values for outputs
    always @(*) begin
        case (aluc)
            SLT, SLTU: flag = 1'b1;
            default: flag = 1'bz;
        endcase

        // Perform the operation based on the control signal
        case (aluc)
            ADD: begin
                res = a + b;
                carry = res[32];
                overflow = (a[31] == b[31]) && (res[31] != a[31]);
            end
            ADDU: begin
                res = a + b;
                carry = res[32];
                overflow = 1'b0;
            end
            SUB: begin
                res = a - b;
                carry = ~res[32];
                overflow = (a[31] != b[31]) && (res[31] != a[31]);
            end
            SUBU: begin
                res = a - b;
                carry = ~res[32];
                overflow = 1'b0;
            end
            AND: res = a & b;
            OR: res = a | b;
            XOR: res = a ^ b;
            NOR: res = ~(a | b);
            SLT: res = (a < b) ? 32'b1 : 32'b0;
            SLTU: res = ($unsigned(a) < $unsigned(b)) ? 32'b1 : 32'b0;
            SLL: res = { b[31:27], b[26:0], 5'b0 }; // Shift left logical (shamt from b[10:6])
            SRL: res = { 5'b0, b[31:5] }; // Shift right logical (shamt from b[10:6])
            SRA: res = { b[31], b[31:31], b[31:5] }; // Shift right arithmetic (shamt from b[10:6])
            SLLV: res = { b[31:32-a[4:0]], b[31:0] }; // Shift left logical variable
            SRLV: res = { b[31:0], b[31:32-a[4:0]] }; // Shift right logical variable
            SRAV: res = { b[31], b[31:31], b[31:0] }; // Shift right arithmetic variable
            LUI: res = { a[15:0], 16'b0 }; // Load upper immediate
            default: res = 33'bz;
        endcase

        // Assign the lower 32 bits of the result to output r
        r = res[31:0];

        // Set zero, negative flags
        zero = (r == 32'b0);
        negative = r[31];
    end
endmodule