module adder_bcd (
    input  [3:0] A,
    input  [3:0] B,
    input        Cin,
    output [3:0] Sum,
    output       Cout
);

    // Perform binary addition of A, B, and Cin
    wire [4:0] binary_sum;
    assign binary_sum = {1'b0, A} + {1'b0, B} + {1'b0, Cin};

    // Extract the lower 4 bits of the binary sum
    wire [3:0] sum_bits = binary_sum[3:0];

    // Check if correction is needed:
    // Correction is needed if the 4-bit sum is greater than 9 (1001)
    // OR if there is a carry out from the 4-bit addition (binary_sum[4] == 1)
    wire need_correction = (sum_bits > 4'd9) | binary_sum[4];

    // If correction is needed, add 6 (0110) to the lower 4 bits
    wire [4:0] corrected_sum;
    assign corrected_sum = need_correction ? (binary_sum + 5'd6) : binary_sum;

    // The 4-bit BCD sum is the lower 4 bits of the corrected sum
    assign Sum = corrected_sum[3:0];

    // The carry-out is the 5th bit of the corrected sum
    assign Cout = corrected_sum[4];

endmodule