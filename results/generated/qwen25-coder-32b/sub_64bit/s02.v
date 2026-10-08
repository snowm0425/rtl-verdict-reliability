module sub_64bit (
    input wire [63:0] A,      // First 64-bit input operand
    input wire [63:0] B,      // Second 64-bit input operand
    output wire [63:0] result, // 64-bit output result
    output wire overflow      // Overflow flag
);

    // Perform the subtraction
    assign result = A - B;

    // Extract the sign bits of A, B, and result
    wire sign_A = A[63];
    wire sign_B = B[63];
    wire sign_result = result[63];

    // Detect overflow conditions
    // Positive overflow: A is positive, B is negative, result is negative
    // Negative overflow: A is negative, B is positive, result is positive
    assign overflow = (sign_A & ~sign_B & ~sign_result) | (~sign_A & sign_B & sign_result);

endmodule