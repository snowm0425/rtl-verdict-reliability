module comparator_4bit (
    input  [3:0] A,       // First 4-bit input operand
    input  [3:0] B,       // Second 4-bit input operand
    output A_greater,     // A is greater than B
    output A_equal,       // A is equal to B
    output A_less         // A is less than B
);

    wire [3:0] diff;      // Result of A - B
    wire borrow;          // Borrow out from the subtraction

    // Perform the subtraction A - B
    // We use a 4-bit full subtractor chain
    assign {borrow, diff} = A - B;

    // Determine the comparison results
    assign A_greater = ~borrow & (|diff); // No borrow and non-zero difference means A > B
    assign A_equal   = ~borrow & ~(|diff); // No borrow and zero difference means A == B
    assign A_less    = borrow;             // Borrow means A < B

endmodule