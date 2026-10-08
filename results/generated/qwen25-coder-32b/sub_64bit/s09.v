module sub_64bit (
    input  [63:0] A,        // First 64-bit input operand
    input  [63:0] B,        // Second 64-bit input operand
    output [63:0] result,   // 64-bit output representing the difference (A - B)
    output        overflow  // 1-bit output indicating overflow
);

    // Perform the subtraction: result = A - B
    assign result = A - B;

    // Overflow detection logic
    // Overflow occurs if:
    // 1. A is positive, B is negative, and result is negative
    // 2. A is negative, B is positive, and result is positive

    // Sign bits of A, B, and result
    wire sign_A = A[63];
    wire sign_B = B[63];
    wire sign_result = result[63];

    // Overflow condition: (sign_A != sign_B) && (sign_A != sign_result)
    assign overflow = (sign_A ^ sign_B) & (sign_A ^ sign_result);

endmodule