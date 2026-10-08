module sub_64bit (
    input  [63:0] A,          // First 64-bit input operand
    input  [63:0] B,          // Second 64-bit input operand
    output [63:0] result,     // 64-bit output representing the difference
    output        overflow    // 1-bit output indicating overflow
);

    // Perform the subtraction
    assign result = A - B;

    // Overflow detection logic
    // Overflow occurs if:
    // 1. A is positive, B is negative, and result is negative
    // 2. A is negative, B is positive, and result is positive

    wire a_sign = A[63];       // Sign bit of A
    wire b_sign = B[63];       // Sign bit of B
    wire res_sign = result[63]; // Sign bit of the result

    // Overflow condition
    assign overflow = (a_sign & ~b_sign & ~res_sign) | (~a_sign & b_sign & res_sign);

endmodule