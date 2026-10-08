module comparator_4bit (
    input  [3:0] A,
    input  [3:0] B,
    output       A_greater,
    output       A_equal,
    output       A_less
);

    // Perform subtraction A - B
    // We use a 4-bit subtractor. The borrow out indicates if A < B.
    wire [3:0] diff;
    wire       borrow_out;

    // Subtractor: A - B = A + (~B) + 1
    // The carry out from the addition is the complement of the borrow.
    // So if carry_out = 0, then there is a borrow (A < B).
    wire [3:0] b_not;
    assign b_not = ~B;

    wire [4:0] add_result;
    // Add A, ~B, and 1 to compute A - B
    assign add_result = {1'b0, A} + {1'b0, b_not} + 1'b1;

    // borrow_out is 1 if there is a borrow (i.e., A < B)
    // In 2's complement subtraction, if the carry out is 0, a borrow occurred.
    assign borrow_out = ~add_result[4];

    // Check if the difference is zero (A == B)
    wire diff_zero = (diff == 4'b0000);

    // The difference bits (lower 4 bits of the addition result)
    assign diff = add_result[3:0];

    // Determine outputs:
    // If borrow_out is 1, then A < B
    // If borrow_out is 0 and diff is zero, then A == B
    // If borrow_out is 0 and diff is non-zero, then A > B

    assign A_less    = borrow_out;
    assign A_equal   = ~borrow_out & (diff == 4'b0000);
    assign A_greater = ~borrow_out & (diff != 4'b0000);

endmodule