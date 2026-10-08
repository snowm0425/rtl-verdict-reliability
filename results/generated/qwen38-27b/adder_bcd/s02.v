module adder_bcd (
    input  wire [3:0] A,
    input  wire [3:0] B,
    input  wire       Cin,
    output wire [3:0] Sum,
    output wire       Cout
);

    wire [3:0] binary_sum;
    wire       carry_from_binary;
    wire       need_correction;
    wire [3:0] corrected_sum;
    wire       final_cout;

    // Perform binary addition of A, B, and Cin
    assign {carry_from_binary, binary_sum} = A + B + Cin;

    // Determine if BCD correction is needed
    // Correction is needed if:
    // 1. The binary sum is greater than 9 (i.e., 10-15)
    // 2. OR there is a carry from the binary addition (which means the sum exceeded 15)
    // Actually, let's think more carefully:
    // The raw binary sum of two BCD digits (0-9) plus carry-in (0-1) can range from 0 to 19.
    // If the result is > 9, we need to add 6 and generate a carry.
    
    // A simpler way: if binary_sum > 9 OR carry_from_binary is 1, then correction is needed.
    // But note: if carry_from_binary is 1, then binary_sum is the lower 4 bits of a sum >= 16,
    // so the actual value is 16 + binary_sum, which is definitely > 9.
    // If carry_from_binary is 0, then the actual value is just binary_sum, so we check if it's > 9.
    
    assign need_correction = (binary_sum > 4'd9) | carry_from_binary;

    // Add correction value of 6 if needed
    assign corrected_sum = binary_sum + (need_correction ? 4'd6 : 4'd0);

    // The final carry-out is 1 if correction was needed
    assign Cout = need_correction;

    // The final sum is the lower 4 bits of the corrected result
    assign Sum = corrected_sum;

endmodule