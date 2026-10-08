module sub_64bit (
    input  [63:0] A,        // First 64-bit input operand
    input  [63:0] B,        // Second 64-bit input operand
    output [63:0] result,   // 64-bit output result
    output       overflow  // 1-bit overflow flag
);

    // Perform binary subtraction: result = A - B
    assign result = A - B;

    // Extract the sign bits of A, B, and result
    wire sign_A = A[63];
    wire sign_B = B[63];
    wire sign_result = result[63];

    // Detect overflow conditions
    // Positive overflow: sign_A == 0, sign_B == 1, sign_result == 1
    // Negative overflow: sign_A == 1, sign_B == 0, sign_result == 0
    assign overflow = (sign_A & ~sign_B & ~sign_result) | (~sign_A & sign_B & sign_result);

endmodule