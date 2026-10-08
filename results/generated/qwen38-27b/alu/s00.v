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

    // Parameters for ALU control
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

    // Internal wires
    wire [31:0] result;
    wire        carry_out;
    wire        overflow_out;
    wire        flag_out;

    // Signed versions for SLT
    signed [31:0] a_signed = a;
    signed [31:0] b_signed = b;

    // Carry and Overflow calculation
    // For ADD:
    //   carry_out = (a + b) > 32'hFFFFFFFF
    //   overflow = (a[31] == b[31]) && (result[31] != a[31])
    // For SUB:
    //   We compute a - b as a + (~b) + 1
    //   carry_out is the carry out of this addition
    //   overflow = (a[31] != b[31]) && (result[31] != a[31])

    wire [31:0] add_result = a + b;
    wire        add_carry  = (add_result < a) || (add_result < b); // Overflow check for unsigned add
    wire        add_overflow = (a[31] == b[31]) && (result[31] != a[31]); // This needs result, so we can't do it directly here without circularity.

    // Let's compute carry and overflow inside the always block or use combinational logic carefully.
    
    // We'll use a combinational approach for the flags based on the operation.
    
    assign zero     = (result == 32'b0);
    assign negative = result[31];
    
    // Flag is only valid for SLT/SLTU
    assign flag = (aluc == SLT)  ? (a_signed < b_signed) :
                  (aluc == SLTU) ? (a < b)               : 1'bz;

    // Carry and Overflow are primarily for ADD/SUB
    // For ADD/ADDU:
    //   carry = carry out of addition
    //   overflow = signed overflow (only for ADD)
    // For SUB/SUBU:
    //   carry = carry out of subtraction (borrow logic)
    //   overflow = signed overflow (only for SUB)

    // We will compute these in the always block to keep it clean, or use separate wires.
    
    wire [31:0] sub_result = a - b;
    wire        sub_carry  = (a >= b); // If a >= b, no borrow, so carry out of internal add is 1.
    wire        sub_overflow = (a[31] != b[31]) && (result[31] != a[31]);

    // Final carry and overflow assignment
    assign carry = (aluc == ADD || aluc == ADDU) ? add_carry :
                   (aluc == SUB || aluc == SUBU) ? sub_carry :
                   1'b0;

    assign overflow = (aluc == ADD) ? add_overflow :
                      (aluc == SUB) ? sub_overflow :
                      1'b0;

    // Main ALU Logic
    always @(*) begin
        case (aluc)
            ADD, ADDU: begin
                result = a + b;
            end
            SUB, SUBU: begin
                result = a - b;
            end
            AND: begin
                result = a & b;
            end
            OR: begin
                result = a | b;
            end
            XOR: begin
                result = a ^ b;
            end
            NOR: begin
                result = ~(a | b);
            end
            SLT: begin
                result = (a_signed < b_signed) ? 32'b1 : 32'b0;
            end
            SLTU: begin
                result = (a < b) ? 32'b1 : 32'b0;
            end
            SLL: begin
                // Shift amount from b[4:0] as per standard MIPS variable shift convention 
                // or if fixed, it would be a constant. 
                // The prompt is ambiguous. Standard MIPS SLL uses a 5-bit immediate.
                // Since we only have a and b, and SLLV uses b[4:0], 
                // I will assume for SLL/SRL/SRA the shift amount is also b[4:0] 
                // OR that 'a' is the data and the shift amount is implicit.
                // However, a more robust interpretation for a generic ALU with only a/b:
                // SLL/SRL/SRA: Shift 'a' by 'b[4:0]' (treating them like variable shifts 
                // but with fixed opcodes). This is the only way to make them work 
                // without additional inputs.
                result = a << b[4:0];
            end
            SRL: begin
                result = a >> b[4:0];
            end
            SRA: begin
                result = $signed(a) >>> b[4:0];
            end
            SLLV: begin
                result = a << b[4:0];
            end
            SRLV: begin
                result = a >> b[4:0];
            end
            SRAV: begin
                result = $signed(a) >>> b[4:0];
            end
            LUI: begin
                // Upper 16 bits of 'a' concatenated with 16 zeros
                result = {a[15:0], 16'b0};
            end
            default: begin
                result = 32'bz;
            end
        endcase
    end

    assign r = result;

endmodule