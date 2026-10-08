module adder_bcd (
    input [3:0] A,    // First BCD input (4-bit, representing a decimal digit from 0 to 9)
    input [3:0] B,    // Second BCD input (4-bit, representing a decimal digit from 0 to 9)
    input Cin,        // Carry-in input (1-bit)
    output [3:0] Sum, // 4-bit output representing the sum of the two BCD inputs, corrected to be a valid BCD digit (0–9)
    output Cout       // Carry-out output (1-bit), used when the sum exceeds the decimal value of 9
);

    // Intermediate signals
    wire [3:0] bin_sum;   // Result of binary addition
    wire [3:0] corr_sum;  // Result after BCD correction
    wire bcd_corr;        // BCD correction flag

    // Binary addition
    assign bin_sum = A + B + Cin;

    // BCD correction flag: Set if bin_sum > 9
    assign bcd_corr = (bin_sum > 4'd9);

    // BCD correction: Add 6 if bin_sum > 9
    assign corr_sum = bin_sum + (bcd_corr ? 4'd6 : 4'd0);

    // Final sum and carry-out
    assign Sum = corr_sum;
    assign Cout = (bcd_corr || (corr_sum > 4'd9));

endmodule