module comparator_3bit (
    input wire [2:0] A,        // First 3-bit input operand
    input wire [2:0] B,        // Second 3-bit input operand
    output wire A_greater,     // Output indicating if A > B
    output wire A_equal,       // Output indicating if A == B
    output wire A_less         // Output indicating if A < B
);

// Internal wires for comparison
wire [2:0] diff;
wire greater, equal, less;

// Calculate the difference between A and B
assign diff = A - B;

// Determine if A is greater than B
assign greater = (A[2] & ~B[2]) | (~B[2] & (A[1] & ~B[1] | ~B[1] & A[0] & ~B[0])) |
                (B[2] & ~A[2] & (A[1] & ~B[1] | ~B[1] & A[0] & ~B[0]));

// Determine if A is equal to B
assign equal = (A[2] == B[2]) & (A[1] == B[1]) & (A[0] == B[0]);

// Determine if A is less than B
assign less = (B[2] & ~A[2]) | (~A[2] & (B[1] & ~A[1] | ~A[1] & B[0] & ~A[0])) |
              (A[2] & ~B[2] & (B[1] & ~A[1] | ~A[1] & B[0] & ~A[0]));

// Assign the final outputs
assign A_greater = greater;
assign A_equal = equal;
assign A_less = less;

endmodule