module adder_bcd (
    input [3:0] A,    // First BCD input
    input [3:0] B,    // Second BCD input
    input Cin,        // Carry-in
    output [3:0] Sum, // 4-bit BCD output
    output Cout       // Carry-out
);

    wire [3:0] binary_sum;  // Intermediate binary sum
    wire [3:0] correction;  // Correction value (0110)
    wire [3:0] corrected_sum; // Sum after correction
    wire adder_carry;        // Carry from the binary addition
    wire correct_carry;      // Carry from the correction addition
    wire need_correction;     // Signal if correction is needed

    // Perform binary addition of A, B, and Cin
    assign binary_sum = A + B + Cin;
    assign adder_carry = (binary_sum > 4'd9); // Check if the sum exceeds 9

    // Correction value is 6 (0110) in BCD
    assign correction = 4'b0110;

    // Determine if correction is needed
    assign need_correction = (binary_sum > 4'd9) || (binary_sum[3] & Cin);

    // Perform addition with correction if needed
    assign corrected_sum = need_correction ? (binary_sum + correction) : binary_sum;
    assign correct_carry = (corrected_sum > 4'd9);

    // Final sum and carry-out
    assign Sum = corrected_sum[3:0];
    assign Cout = adder_carry || correct_carry;

endmodule