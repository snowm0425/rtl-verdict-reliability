module sub_64bit (
    input  [63:0] A,
    input  [63:0] B,
    output [63:0] result,
    output overflow
);

    // Perform subtraction: A - B
    assign result = A - B;

    // Overflow detection for subtraction:
    // Overflow occurs when:
    //   - A is positive (A[63] == 0) and B is negative (B[63] == 1) and result is negative (result[63] == 1)
    //   - A is negative (A[63] == 1) and B is positive (B[63] == 0) and result is positive (result[63] == 0)
    // This can be expressed as:
    //   overflow = (A[63] != B[63]) && (A[63] == result[63])
    // Let's verify:
    //   Case 1: A positive (0), B negative (1): A[63] != B[63] is true. Result negative (1): A[63] (0) == result[63] (1)? No.
    //   Wait, that doesn't match. Let me re-think.
    //
    // Actually, for subtraction A - B, overflow occurs when:
    //   - A is positive and B is negative, and the result is negative
    //   - A is negative and B is positive, and the result is positive
    //
    // In terms of sign bits:
    //   Case 1: A[63]==0, B[63]==1, result[63]==1
    //   Case 2: A[63]==1, B[63]==0, result[63]==0
    //
    // This can be written as:
    //   overflow = (~A[63] & B[63] & result[63]) | (A[63] & ~B[63] & ~result[63])
    //
    // Alternatively, we can use the carry-out approach. For subtraction A - B = A + (~B) + 1,
    // overflow = carry_in_to_sign XOR carry_out_from_sign, where carry_in_to_sign is the carry into the MSB from the addition of A + (~B) + 1.
    //
    // But the problem statement gives a specific description, so let's follow it directly.

    wire pos_overflow = ~A[63] & B[63] & result[63];
    wire neg_overflow = A[63] & ~B[63] & ~result[63];

    assign overflow = pos_overflow | neg_overflow;

endmodule