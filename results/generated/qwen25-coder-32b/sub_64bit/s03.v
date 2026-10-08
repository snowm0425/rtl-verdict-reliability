module sub_64bit (
    input  [63:0] A,        // First 64-bit input operand
    input  [63:0] B,        // Second 64-bit input operand
    output [63:0] result,   // 64-bit output representing the difference
    output       overflow   // 1-bit output indicating overflow
);

    // Perform the subtraction
    assign result = A - B;

    // Detect overflow conditions
    // Overflow occurs if:
    // 1. A is positive, B is negative, and result is negative
    // 2. A is negative, B is positive, and result is positive

    // Sign bits of A, B, and result
    wire sign_A = A[63];
    wire sign_B = B[63];
    wire sign_result = result[63];

    // Overflow detection logic
    assign overflow = (sign_A & ~sign_B & ~sign_result) | (~sign_A & sign_B & sign_result);

endmodule