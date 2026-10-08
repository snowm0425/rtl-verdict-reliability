module adder_bcd (
    input [3:0] A,    // First BCD input
    input [3:0] B,    // Second BCD input
    input Cin,        // Carry-in
    output [3:0] Sum, // 4-bit BCD sum output
    output Cout       // Carry-out
);

    wire [3:0] binary_sum; // Intermediate binary sum
    wire [3:0] correction; // Correction value (0110)
    wire [3:0] pre_sum;    // Pre-corrected sum
    wire add_6;            // Signal to add 6 if sum exceeds 9

    // Binary addition of A, B, and Cin
    assign binary_sum = A + B + Cin;

    // Determine if the sum exceeds 9 (1001 in binary)
    assign add_6 = (binary_sum > 4'd9);

    // Correction value is 6 (0110) if the sum exceeds 9
    assign correction = add_6 ? 4'd6 : 4'd0;

    // Pre-sum is the binary sum plus the correction
    assign pre_sum = binary_sum + correction;

    // Final BCD sum is the lower 4 bits of pre_sum
    assign Sum = pre_sum[3:0];

    // Carry-out is the OR of the carry from binary_sum and the add_6 signal
    assign Cout = (binary_sum[4] | add_6);

endmodule