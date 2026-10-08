module adder_bcd (
    input [3:0] A,    // First BCD input (4-bit)
    input [3:0] B,    // Second BCD input (4-bit)
    input Cin,        // Carry-in input (1-bit)
    output [3:0] Sum, // 4-bit output representing the BCD sum
    output Cout       // Carry-out output (1-bit)
);

    // Intermediate signals
    reg [3:0] binary_sum;  // Result of binary addition
    reg [3:0] corrected_sum; // Result after BCD correction
    reg add_6;             // Signal to indicate if 6 should be added for BCD correction
    reg binary_cout;       // Carry-out from binary addition

    // Perform binary addition
    assign binary_sum = A + B + Cin;
    assign binary_cout = (binary_sum > 4'd9);

    // Determine if correction is needed
    assign add_6 = (binary_sum > 4'd9) || (binary_sum == 4'd10 && Cin);

    // Correct the sum if it exceeds 9
    assign corrected_sum = binary_sum + (add_6 ? 4'd6 : 4'd0);

    // Final Sum and Cout assignments
    assign Sum = corrected_sum[3:0];
    assign Cout = (binary_cout || (corrected_sum > 4'd9));

endmodule