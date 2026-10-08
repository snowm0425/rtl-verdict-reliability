module sub_64bit (
    input  wire [63:0] A,        // First 64-bit input operand
    input  wire [63:0] B,        // Second 64-bit input operand
    output wire [63:0] result,   // 64-bit output result of A - B
    output wire        overflow   // Overflow flag
);

    // Perform subtraction: result = A - B
    assign result = A - B;

    // Overflow detection
    // Overflow occurs if:
    // 1. A is positive, B is negative, and result is negative (positive overflow)
    // 2. A is negative, B is positive, and result is positive (negative overflow)

    // Sign bits of A, B, and result
    wire sign_A = A[63];
    wire sign_B = B[63];
    wire sign_result = result[63];

    // Positive overflow: (sign_A == 0) && (sign_B == 1) && (sign_result == 1)
    wire positive_overflow = ~sign_A & sign_B & sign_result;

    // Negative overflow: (sign_A == 1) && (sign_B == 0) && (sign_result == 0)
    wire negative_overflow = sign_A & ~sign_B & ~sign_result;

    // Combine positive and negative overflow conditions
    assign overflow = positive_overflow | negative_overflow;

endmodule