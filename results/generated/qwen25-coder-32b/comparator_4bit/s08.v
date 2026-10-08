module comparator_4bit (
    input  [3:0] A,        // First 4-bit input operand
    input  [3:0] B,        // Second 4-bit input operand
    output A_greater,      // A is greater than B
    output A_equal,        // A is equal to B
    output A_less          // A is less than B
);

    wire [3:0] diff;       // Result of A - B
    wire borrow;           // Borrow out of the subtraction

    // Perform the subtraction A - B
    assign {borrow, diff} = A - B;

    // Determine the relationship between A and B
    assign A_greater = ~borrow & (|diff);  // A is greater if no borrow and diff is non-zero
    assign A_equal   = ~borrow & ~(|diff); // A is equal if no borrow and diff is zero
    assign A_less    = borrow;             // A is less if borrow occurs

endmodule