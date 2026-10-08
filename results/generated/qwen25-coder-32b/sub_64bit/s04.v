module sub_64bit (
    input  wire [63:0] A,       // First 64-bit input operand
    input  wire [63:0] B,       // Second 64-bit input operand
    output wire [63:0] result,  // 64-bit output representing the difference (A - B)
    output wire        overflow  // 1-bit output indicating overflow
);

    // Perform the subtraction
    assign result = A - B;

    // Overflow detection logic
    // Overflow occurs if:
    // 1. A and B have different signs and the result has a sign different from A
    wire a_sign = A[63];  // Sign bit of A (1 for negative, 0 for positive)
    wire b_sign = B[63];  // Sign bit of B (1 for negative, 0 for positive)
    wire res_sign = result[63];  // Sign bit of the result (1 for negative, 0 for positive)

    // Overflow condition: (a_sign != b_sign) && (a_sign != res_sign)
    assign overflow = (a_sign ^ b_sign) & (a_sign ^ res_sign);

endmodule