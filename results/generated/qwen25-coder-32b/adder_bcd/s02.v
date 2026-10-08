module adder_bcd (
    input [3:0] A,    // First BCD input
    input [3:0] B,    // Second BCD input
    input Cin,        // Carry-in input
    output [3:0] Sum, // 4-bit BCD output
    output Cout       // Carry-out output
);

    wire [3:0] binary_sum; // Result of binary addition
    wire [3:0] correction; // Correction value (0110)
    wire [3:0] pre_bcd_sum; // Pre BCD correction sum
    wire bcd_correction_needed; // Flag to indicate if BCD correction is needed

    // Binary addition of A, B, and Cin
    assign binary_sum = A + B + Cin;

    // Determine if BCD correction is needed (if binary_sum > 9)
    assign bcd_correction_needed = (binary_sum > 4'd9);

    // Assign correction value (0110) if BCD correction is needed, otherwise 0000
    assign correction = bcd_correction_needed ? 4'd6 : 4'd0;

    // Pre BCD correction sum
    assign pre_bcd_sum = binary_sum + correction;

    // Final BCD sum is the lower 4 bits of pre_bcd_sum
    assign Sum = pre_bcd_sum[3:0];

    // Carry-out is set if bcd_correction_needed is true or if the pre_bcd_sum exceeds 15
    assign Cout = bcd_correction_needed || (pre_bcd_sum > 4'd9);

endmodule