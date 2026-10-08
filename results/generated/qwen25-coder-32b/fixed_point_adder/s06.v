module fixed_point_adder #(
    parameter Q = 8,  // Number of fractional bits
    parameter N = 16  // Total number of bits
)(
    input  [N-1:0] a,  // First N-bit fixed-point input operand
    input  [N-1:0] b,  // Second N-bit fixed-point input operand
    output [N-1:0] c   // N-bit output representing the result
);

    // Internal wire declarations
    wire signed [N:0] sum;  // Sum with one extra bit for overflow detection
    wire [N-1:0] abs_a;     // Absolute value of a
    wire [N-1:0] abs_b;     // Absolute value of b
    wire a_pos;             // Sign bit of a (0 for positive, 1 for negative)
    wire b_pos;             // Sign bit of b (0 for positive, 1 for negative)
    wire [N-1:0] result;    // Result of the operation

    // Extract sign bits
    assign a_pos = ~a[N-1];
    assign b_pos = ~b[N-1];

    // Compute absolute values
    assign abs_a = a_pos ? a : -a;
    assign abs_b = b_pos ? b : -b;

    // Perform addition or subtraction based on the sign bits
    always @(*) begin
        if (a_pos == b_pos) begin
            // Both numbers have the same sign, add their absolute values
            sum = abs_a + abs_b;
            result = a_pos ? sum[N-1:0] : ~sum[N-1:0] + 1'b1;  // Ensure the sign bit is correct
        end else begin
            // Numbers have different signs, perform subtraction
            if (abs_a > abs_b) begin
                sum = abs_a - abs_b;
                result = sum[N-1:0];  // Result is positive
            end else begin
                sum = abs_b - abs_a;
                result = ~sum[N-1:0] + 1'b1;  // Result is negative
            end
        end
    end

    // Handle overflow
    // If there's an overflow, the result should be saturated to the maximum or minimum value
    assign c = (sum[N] && (result[N-1] == 0)) ? {N{1'b1}} :  // Overflow to max negative
              (!sum[N] && (result[N-1] == 1)) ? {N{1'b0}} :  // Overflow to zero
              result;  // No overflow, use the result

endmodule