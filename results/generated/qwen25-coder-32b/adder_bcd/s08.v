module adder_bcd (
    input [3:0] A,      // First BCD input (4-bit)
    input [3:0] B,      // Second BCD input (4-bit)
    input       Cin,    // Carry-in input (1-bit)
    output [3:0] Sum,   // 4-bit BCD output sum
    output      Cout    // Carry-out output (1-bit)
);

    // Internal signals
    wire [3:0] binary_sum;  // Result of binary addition
    wire [3:0] correction;  // Correction value (0 or 6)
    wire [3:0] corrected_sum; // Result after BCD correction
    wire       carry_out;    // Carry-out from binary addition
    wire       bcd_carry_out; // Carry-out after BCD correction

    // Binary addition of A, B, and Cin
    assign binary_sum = A + B + Cin;
    assign carry_out = (binary_sum > 9);

    // Determine the correction value
    assign correction = carry_out ? 4'b0110 : 4'b0000;

    // Apply the correction to the binary sum
    assign corrected_sum = binary_sum + correction;
    assign bcd_carry_out = (corrected_sum > 9);

    // Final BCD sum and carry-out
    assign Sum = corrected_sum[3:0];
    assign Cout = carry_out | bcd_carry_out;

endmodule