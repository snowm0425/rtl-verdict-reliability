module sub_64bit (
    input  [63:0] A,
    input  [63:0] B,
    output [63:0] result,
    output        overflow
);

    // Perform subtraction: A - B
    assign result = A - B;

    // Overflow detection for subtraction:
    // Overflow occurs when:
    // - A is positive (sign bit 0), B is negative (sign bit 1), and result is negative (sign bit 1)
    //   This is positive overflow: A - (-|B|) = A + |B|, which can overflow if too large.
    // - A is negative (sign bit 1), B is positive (sign bit 0), and result is positive (sign bit 0)
    //   This is negative overflow: A - |B| = A + (-|B|), which can underflow if too small.

    wire a_sign = A[63];
    wire b_sign = B[63];
    wire r_sign = result[63];

    // Positive overflow: A >= 0, B < 0, result < 0
    wire pos_overflow = (~a_sign) & b_sign & r_sign;

    // Negative overflow: A < 0, B >= 0, result >= 0
    wire neg_overflow = a_sign & (~b_sign) & (~r_sign);

    assign overflow = pos_overflow | neg_overflow;

endmodule