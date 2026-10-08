module comparator_4bit (
    input [3:0] A,          // First 4-bit input operand
    input [3:0] B,          // Second 4-bit input operand
    output reg A_greater,   // Output indicating if A is greater than B
    output reg A_equal,     // Output indicating if A is equal to B
    output reg A_less       // Output indicating if A is less than B
);

    wire [3:0] diff;        // Result of A - B
    wire borrow;            // Borrow out from the subtraction

    // Perform A - B using full subtractors
    wire [3:0] b_inv;       // Inverted B for subtraction
    wire [3:0] C_in;        // Borrow in for each bit position

    // Invert B for subtraction
    assign b_inv = ~B;

    // Initialize borrow in to 1 (to handle the borrow out from the most significant bit)
    assign C_in[0] = 1'b1;

    // Instantiate 4 full subtractors for each bit position
    genvar i;
    generate
        for (i = 0; i < 4; i = i + 1) begin : gen_subtractors
            full_subtractor fs (
                .a(A[i]),
                .b(b_inv[i]),
                .cin(C_in[i]),
                .diff(diff[i]),
                .cout(C_in[i+1])
            );
        end
    endgenerate

    // Assign the final borrow out
    assign borrow = C_in[4];

    // Determine the comparison results
    assign A_equal = (diff == 4'b0000);
    assign A_greater = (borrow == 1'b0) && (A != B);
    assign A_less = borrow;

endmodule

// Full subtractor module
module full_subtractor (
    input a,                // Minuend bit
    input b,                // Subtrahend bit (inverted)
    input cin,              // Borrow in
    output diff,            // Difference bit
    output cout             // Borrow out
);

    // Full subtractor logic
    assign diff = a ^ b ^ cin;
    assign cout = (a & ~b) | (cin & ~b) | (a & cin);

endmodule