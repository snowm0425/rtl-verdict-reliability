module adder_bcd (
    input [3:0] A,    // First BCD input (4-bit, representing a decimal digit from 0 to 9)
    input [3:0] B,    // Second BCD input (4-bit, representing a decimal digit from 0 to 9)
    input Cin,        // Carry-in input (1-bit)
    output [3:0] Sum, // 4-bit output representing the sum of the two BCD inputs, corrected to be a valid BCD digit (0–9)
    output Cout       // Carry-out output (1-bit), used when the sum exceeds the decimal value of 9
);

    // Internal signals
    wire [4:0] bin_sum;    // Binary sum of A, B, and Cin
    wire [3:0] corrected_sum; // Corrected BCD sum
    wire bcd_correction;     // Signal to indicate if BCD correction is needed

    // Binary addition of A, B, and Cin
    assign bin_sum = A + B + Cin;

    // Determine if BCD correction is needed (if bin_sum > 9)
    assign bcd_correction = (bin_sum > 9);

    // Apply BCD correction if needed
    assign corrected_sum = bcd_correction ? (bin_sum + 6) : bin_sum;

    // Output the corrected sum and carry-out
    assign Sum = corrected_sum[3:0];
    assign Cout = bcd_correction || (corrected_sum > 9);

endmodule