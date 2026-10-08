module sub_64bit (
    input  [63:0] A,        // First 64-bit input operand
    input  [63:0] B,        // Second 64-bit input operand
    output [63:0] result,   // 64-bit output representing the difference of A and B
    output        overflow  // 1-bit output indicating overflow
);

    // Perform the subtraction
    assign result = A - B;

    // Overflow detection logic
    wire sign_A = A[63];     // Sign bit of A
    wire sign_B = B[63];     // Sign bit of B
    wire sign_result = result[63]; // Sign bit of the result

    // Positive overflow: A is positive, B is negative, result is negative
    // Negative overflow: A is negative, B is positive, result is positive
    assign overflow = (sign_A & ~sign_B & ~sign_result) | (~sign_A & sign_B & sign_result);

endmodule