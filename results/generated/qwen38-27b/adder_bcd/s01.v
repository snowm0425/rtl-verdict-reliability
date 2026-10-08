module adder_bcd (
    input  wire [3:0] A,
    input  wire [3:0] B,
    input  wire       Cin,
    output wire [3:0] Sum,
    output wire       Cout
);

    // Binary addition of A, B, and Cin
    wire [4:0] binary_sum = {1'b0, A} + {1'b0, B} + {4'b0, Cin};

    // Determine if correction is needed
    // Correction is needed if binary_sum > 9 (i.e., >= 10)
    wire need_correction = (binary_sum > 4'd9);

    // If correction is needed, add 6 (0110) to the lower 4 bits
    // The carry-out is 1 if correction is needed
    assign Cout = need_correction;

    // If correction is needed, add 6 to the 4-bit sum
    // Otherwise, keep the binary sum
    assign Sum = need_correction ? (binary_sum[3:0] + 4'd6) : binary_sum[3:0];

endmodule