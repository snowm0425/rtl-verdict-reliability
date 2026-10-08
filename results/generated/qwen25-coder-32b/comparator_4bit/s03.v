module comparator_4bit (
    input [3:0] A,          // First 4-bit input operand
    input [3:0] B,          // Second 4-bit input operand
    output A_greater,       // Output: A is greater than B
    output A_equal,         // Output: A is equal to B
    output A_less           // Output: A is less than B
);

    // Intermediate signals
    wire [3:0] diff;        // Result of A - B
    wire [3:0] borrow;      // Borrow signal for each bit

    // Full Subtractors for each bit position
    // Full Subtractor for the least significant bit (LSB)
    assign diff[0] = A[0] ^ B[0] ^ borrow[0];
    assign borrow[0] = (~A[0] & B[0]) | (B[0] & borrow[0]) | (~A[0] & borrow[0]);

    // Full Subtractors for the remaining bits
    genvar i;
    generate
        for (i = 1; i < 4; i = i + 1) begin : gen_full_subtractors
            assign diff[i] = A[i] ^ B[i] ^ borrow[i];
            assign borrow[i] = (~A[i] & B[i]) | (B[i] & borrow[i-1]) | (~A[i] & borrow[i-1]);
        end
    endgenerate

    // Output assignments
    // A is greater than B if there is no borrow out and the result is non-zero
    assign A_greater = ~borrow[3] & |diff;

    // A is equal to B if there is no borrow out and the result is zero
    assign A_equal = ~borrow[3] & ~|diff;

    // A is less than B if there is a borrow out
    assign A_less = borrow[3];

endmodule