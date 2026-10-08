module comparator_4bit (
    input wire [3:0] A,       // First 4-bit input operand
    input wire [3:0] B,       // Second 4-bit input operand
    output reg A_greater,     // Output: A is greater than B
    output reg A_equal,       // Output: A is equal to B
    output reg A_less         // Output: A is less than B
);

    // Temporary variables to hold the result of the subtraction
    wire [3:0] diff;
    // Borrow out from the subtraction
    wire borrow;

    // Perform the subtraction A - B
    // Using full subtractor for each bit position
    wire [3:0] b_not = ~B; // Invert B for subtraction
    wire [3:0] b_plus_one;
    full_adder fa0 (b_not[0], 1'b1, 1'b0, b_plus_one[0], borrow); // Add 1 to the inverted B[0]
    full_adder fa1 (b_not[1], borrow, 1'b0, b_plus_one[1], borrow);
    full_adder fa2 (b_not[2], borrow, 1'b0, b_plus_one[2], borrow);
    full_adder fa3 (b_not[3], borrow, 1'b0, b_plus_one[3], borrow);

    // Perform the actual subtraction A + (~B + 1)
    full_adder fa4 (A[0], b_plus_one[0], 1'b0, diff[0], borrow);
    full_adder fa5 (A[1], b_plus_one[1], borrow, diff[1], borrow);
    full_adder fa6 (A[2], b_plus_one[2], borrow, diff[2], borrow);
    full_adder fa7 (A[3], b_plus_one[3], borrow, diff[3], borrow);

    // Determine the relationship between A and B
    assign A_less = borrow; // If borrow is 1, A < B

    // A_equal is true if the result of the subtraction is zero
    assign A_equal = (diff == 4'b0000);

    // A_greater is true if A is not equal to B and no borrow occurred
    assign A_greater = ~A_equal & ~A_less;

endmodule

// Full adder module
module full_adder (
    input wire a,
    input wire b,
    input wire cin,
    output reg sum,
    output reg cout
);
    assign sum = a ^ b ^ cin;
    assign cout = (a & b) | (cin & (a ^ b));
endmodule