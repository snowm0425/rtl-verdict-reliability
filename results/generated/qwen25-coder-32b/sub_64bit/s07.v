module sub_64bit (
    input  [63:0] A,        // First 64-bit input operand
    input  [63:0] B,        // Second 64-bit input operand
    output [63:0] result,   // 64-bit output representing the difference (A - B)
    output        overflow  // 1-bit output indicating overflow
);

    // Perform the subtraction
    assign result = A - B;

    // Detect overflow
    // Overflow occurs if:
    // 1. A is positive, B is negative, and result is negative (Positive overflow)
    // 2. A is negative, B is positive, and result is positive (Negative overflow)

    // Sign bits of A, B, and result
    wire sign_A = A[63];
    wire sign_B = B[63];
    wire sign_result = result[63];

    // Positive overflow: (A > 0) && (B < 0) && (result < 0)
    wire pos_overflow = ~sign_A & sign_B & sign_result;

    // Negative overflow: (A < 0) && (B > 0) && (result > 0)
    wire neg_overflow = sign_A & ~sign_B & ~sign_result;

    // Combine positive and negative overflow conditions
    assign overflow = pos_overflow | neg_overflow;

endmodule