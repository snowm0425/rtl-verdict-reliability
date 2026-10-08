module adder_bcd (
    input [3:0] A,      // First BCD input
    input [3:0] B,      // Second BCD input
    input Cin,          // Carry-in input
    output [3:0] Sum,   // 4-bit BCD output
    output Cout         // Carry-out output
);

    wire [4:0] binary_sum;  // Intermediate binary sum including carry-in
    wire [3:0] corrected_sum; // Corrected sum after BCD correction
    wire bcd_correction_needed; // Signal to indicate if BCD correction is needed

    // Perform binary addition of A, B, and Cin
    assign binary_sum = A + B + Cin;

    // Determine if BCD correction is needed (sum > 9)
    assign bcd_correction_needed = (binary_sum > 4'd9);

    // Perform BCD correction if needed
    assign corrected_sum = bcd_correction_needed ? (binary_sum + 4'd6) : binary_sum[3:0];

    // Assign the corrected sum to the output Sum
    assign Sum = corrected_sum;

    // Generate carry-out if the corrected sum exceeds 9
    assign Cout = bcd_correction_needed || (binary_sum[4]);

endmodule