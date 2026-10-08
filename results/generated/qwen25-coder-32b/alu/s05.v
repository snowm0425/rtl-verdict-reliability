module alu (
    input wire [31:0] a,
    input wire [31:0] b,
    input wire [5:0] aluc,
    output reg [31:0] r,
    output reg zero,
    output reg carry,
    output reg negative,
    output reg overflow,
    output reg flag
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

    // Internal registers to store results
    reg [32:0] res; // 33 bits to capture carry for overflow detection

    // Default assignments
    always @(*) begin
        case (aluc)
            ADD, ADDU: begin
                res = a + b;
                carry = res[32];
                overflow = (a[31] == b[31]) && (a[31] != res[31]);
            end
            SUB, SUBU: begin
                res = a - b;
                carry = ~res[32];
                overflow = (a[31] != b[31]) && (a[31] != res[31]);
            end
            AND: res = a & b;
            OR: res = a | b;
            XOR: res = a ^ b;
            NOR: res = ~(a | b);
            SLT: begin
                res = ($signed(a) < $signed(b)) ? 32'b1 : 32'b0;
                flag = res[0];
            end
            SLTU: begin
                res = (a < b) ? 32'b1 : 32'b0;
                flag = res[0];
            end
            SLL: res = a << b[4:0];
            SRL: res = a >> b[4:0];
            SRA: res = {a[31], a[31:1]} >> b[4:0];
            SLLV: res = a << b;
            SRLV: res = a >> b;
            SRAV: res = {a[31], a[31:1]} >> b;
            LUI: res = {a[15:0], 16'b0};
            default: res = 33'bZ;
        endcase

        // Assign the lower 32 bits of res to the output r
        r = res[31:0];

        // Set zero, negative flags
        zero = (res[31:0] == 32'b0);
        negative = res[31];

        // Set flag to 'z' for operations other than SLT and SLTU
        if (aluc != SLT && aluc != SLTU) begin
            flag = 1'bz;
        end
    end
endmodule