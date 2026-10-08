module alu (
    input  wire [31:0] a,
    input  wire [31:0] b,
    input  wire [5:0]  aluc,
    output reg  [31:0] r,
    output reg         zero,
    output reg         carry,
    output reg         negative,
    output reg         overflow,
    output reg         flag
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

    // Internal signals
    reg [31:0] res;

    // Combinational logic to determine the output based on the aluc signal
    always @(*) begin
        case (aluc)
            ADD: begin
                res = a + b;
                carry = (a[31] & b[31] & ~res[31]) | (~a[31] & b[31] & ~res[31]) | (a[31] & ~b[31] & ~res[31]);
                overflow = (a[31] & b[31] & ~res[31]) | (~a[31] & ~b[31] & res[31]);
                flag = 1'bz;
            end

            ADDU: begin
                res = a + b;
                carry = (a[31] & b[31] & ~res[31]) | (~a[31] & b[31] & ~res[31]) | (a[31] & ~b[31] & ~res[31]);
                overflow = 1'bz;
                flag = 1'bz;
            end

            SUB: begin
                res = a - b;
                carry = (~a[31] & b[31] & res[31]) | (a[31] & ~b[31] & res[31]) | (~a[31] & ~b[31] & ~res[31]);
                overflow = (~a[31] & b[31] & res[31]) | (a[31] & ~b[31] & ~res[31]);
                flag = 1'bz;
            end

            SUBU: begin
                res = a - b;
                carry = (~a[31] & b[31] & res[31]) | (a[31] & ~b[31] & res[31]) | (~a[31] & ~b[31] & ~res[31]);
                overflow = 1'bz;
                flag = 1'bz;
            end

            AND: begin
                res = a & b;
                carry = 1'bz;
                overflow = 1'bz;
                flag = 1'bz;
            end

            OR: begin
                res = a | b;
                carry = 1'bz;
                overflow = 1'bz;
                flag = 1'bz;
            end

            XOR: begin
                res = a ^ b;
                carry = 1'bz;
                overflow = 1'bz;
                flag = 1'bz;
            end

            NOR: begin
                res = ~(a | b);
                carry = 1'bz;
                overflow = 1'bz;
                flag = 1'bz;
            end

            SLT: begin
                res = (a < b) ? 32'b1 : 32'b0;
                carry = 1'bz;
                overflow = 1'bz;
                flag = (a < b) ? 1'b1 : 1'b0;
            end

            SLTU: begin
                res = ($unsigned(a) < $unsigned(b)) ? 32'b1 : 32'b0;
                carry = 1'bz;
                overflow = 1'bz;
                flag = ($unsigned(a) < $unsigned(b)) ? 1'b1 : 1'b0;
            end

            SLL: begin
                res = a << b[4:0];
                carry = 1'bz;
                overflow = 1'bz;
                flag = 1'bz;
            end

            SRL: begin
                res = a >> b[4:0];
                carry = 1'bz;
                overflow = 1'bz;
                flag = 1'bz;
            end

            SRA: begin
                res = $signed(a) >>> b[4:0];
                carry = 1'bz;
                overflow = 1'bz;
                flag = 1'bz;
            end

            SLLV: begin
                res = a << b[4:0];
                carry = 1'bz;
                overflow = 1'bz;
                flag = 1'bz;
            end

            SRLV: begin
                res = a >> b[4:0];
                carry = 1'bz;
                overflow = 1'bz;
                flag = 1'bz;
            end

            SRAV: begin
                res = $signed(a) >>> b[4:0];
                carry = 1'bz;
                overflow = 1'bz;
                flag = 1'bz;
            end

            LUI: begin
                res = {a[15:0], 16'b0};
                carry = 1'bz;
                overflow = 1'bz;
                flag = 1'bz;
            end

            default: begin
                res = 32'bz;
                carry = 1'bz;
                overflow = 1'bz;
                flag = 1'bz;
            end
        endcase

        // Set zero, negative flags
        zero = (res == 32'b0) ? 1'b1 : 1'b0;
        negative = res[31];
    end

    // Assign the result to the output
    assign r = res;

endmodule