module comparator_4bit (
    input [3:0] A,      // First 4-bit input operand
    input [3:0] B,      // Second 4-bit input operand
    output reg A_greater, // Output: A is greater than B
    output reg A_equal,   // Output: A is equal to B
    output reg A_less     // Output: A is less than B
);

    // Intermediate signals
    wire [3:0] diff;    // Result of A - B
    wire borrow;         // Borrow signal from the subtraction

    // Full subtractor for each bit position
    wire borrow1, borrow2, borrow3;

    // Subtracting bit 0
    assign diff[0] = A[0] ^ B[0] ^ borrow;
    assign borrow1 = (~A[0] & B[0]) | (borrow & (~A[0] | B[0]));

    // Subtracting bit 1
    assign diff[1] = A[1] ^ B[1] ^ borrow1;
    assign borrow2 = (~A[1] & B[1]) | (borrow1 & (~A[1] | B[1]));

    // Subtracting bit 2
    assign diff[2] = A[2] ^ B[2] ^ borrow2;
    assign borrow3 = (~A[2] & B[2]) | (borrow2 & (~A[2] | B[2]));

    // Subtracting bit 3
    assign diff[3] = A[3] ^ B[3] ^ borrow3;
    assign borrow = (~A[3] & B[3]) | (borrow3 & (~A[3] | B[3]));

    // Determine the outputs based on the result of subtraction and borrow
    always @(*) begin
        A_greater = 0;
        A_equal = 0;
        A_less = 0;

        if (borrow) begin
            // A is less than B if there is a borrow
            A_less = 1;
        end else begin
            // Check if the result of subtraction is zero (A is equal to B)
            if (diff == 4'b0000) begin
                A_equal = 1;
            end else begin
                // If no borrow and the result is non-zero, A is greater than B
                A_greater = 1;
            end
        end
    end

endmodule