module adder_bcd (
    input  [3:0] A,
    input  [3:0] B,
    input        Cin,
    output [3:0] Sum,
    output       Cout
);

    wire [4:0] binary_sum;
    wire       carry_from_adder;
    wire       bcd_carry;
    wire [3:0] corrected_sum;

    // Binary addition of A, B, and Cin
    assign binary_sum = A + B + Cin;
    assign carry_from_adder = binary_sum[4];

    // BCD correction condition:
    // If the binary sum (ignoring the 5th bit) is greater than 9, or if there's a carry out from the 4-bit addition,
    // we need to add 6 to correct the result.
    // Specifically:
    // - If binary_sum[3:0] > 9 (i.e., 10 to 15), correction is needed.
    // - If carry_from_adder is 1, correction is also needed (since the actual sum is 16-23, which definitely exceeds 9).
    
    // The condition for BCD correction:
    // bcd_carry = 1 if (binary_sum[3:0] > 9) OR (carry_from_adder == 1)
    // Note: If carry_from_adder is 1, binary_sum[3:0] is in range 0-7, but the total sum is 16-23, so we definitely need correction.
    
    wire [3:0] sum4 = binary_sum[3:0];
    wire       sum_gt_9 = (sum4 >= 10'd10);
    
    assign bcd_carry = sum_gt_9 | carry_from_adder;

    // Add correction of 6 if needed
    assign corrected_sum = sum4 + (bcd_carry ? 4'd6 : 4'd0);

    // Final outputs
    assign Sum  = corrected_sum;
    assign Cout = bcd_carry;

endmodule