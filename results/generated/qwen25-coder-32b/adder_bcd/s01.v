module adder_bcd (
    input [3:0] A,    // First BCD input
    input [3:0] B,    // Second BCD input
    input Cin,        // Carry-in
    output [3:0] Sum, // 4-bit BCD output
    output Cout       // Carry-out
);

    // Internal signals
    wire [3:0] binary_sum;    // Result of binary addition
    wire [3:0] corrected_sum; // Result after BCD correction
    wire carry_out;            // Carry-out before correction

    // Perform binary addition
    assign binary_sum = A + B + Cin;

    // Determine if correction is needed
    wire need_correction = (binary_sum > 9);

    // Perform BCD correction if needed (add 6 to the sum)
    assign corrected_sum = binary_sum + (need_correction ? 4'b0110 : 4'b0000);

    // Final sum and carry-out
    assign Sum = corrected_sum[3:0];
    assign Cout = (need_correction || (corrected_sum > 9));

endmodule