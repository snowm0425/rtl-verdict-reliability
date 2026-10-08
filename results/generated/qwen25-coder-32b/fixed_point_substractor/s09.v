module fixed_point_subtractor #(
    parameter N = 16,  // Total number of bits (both integer and fractional)
    parameter Q = 8    // Number of fractional bits
) (
    input  [N-1:0] a,  // First fixed-point input operand
    input  [N-1:0] b,  // Second fixed-point input operand
    output [N-1:0] c   // Result of the fixed-point subtraction
);

    // Internal register to store the result
    reg [N-1:0] res;

    // Wire to determine the sign of the inputs
    wire a_is_negative = a[N-1];
    wire b_is_negative = b[N-1];

    // Wire to store the absolute values of a and b
    wire [N-1:0] abs_a = a_is_negative ? (~a + 1) : a;
    wire [N-1:0] abs_b = b_is_negative ? (~b + 1) : b;

    // Wire to determine the result's sign
    wire result_is_negative;

    // Perform the subtraction based on the signs of a and b
    always @(*) begin
        if (a_is_negative == b_is_negative) begin
            // Same sign subtraction
            res = a - b;
            result_is_negative = a_is_negative;
        end else begin
            // Different sign subtraction
            if (a_is_negative) begin
                // a is negative, b is positive
                res = abs_a + abs_b;
                result_is_negative = (abs_a > abs_b);
            end else begin
                // a is positive, b is negative
                res = abs_a + abs_b;
                result_is_negative = (abs_a < abs_b);
            end
        end

        // Adjust the sign of the result
        if (result_is_negative) begin
            c = ~res + 1;
        end else begin
            c = res;
        end

        // Handle zero explicitly
        if (res == 0) begin
            c = 0;
        end
    end

endmodule