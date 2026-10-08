module fixed_point_adder #(
    parameter Q = 4,  // Number of fractional bits (precision)
    parameter N = 8   // Total number of bits (including integer and fractional parts)
)(
    input  [N-1:0] a,  // First N-bit fixed-point input operand
    input  [N-1:0] b,  // Second N-bit fixed-point input operand
    output [N-1:0] c   // N-bit output representing the result of the fixed-point addition
);

    // Internal register to store the result
    reg [N-1:0] res;

    // Intermediate signals
    wire a_sign = a[N-1];  // Sign bit of a
    wire b_sign = b[N-1];  // Sign bit of b
    wire [N-1:0] abs_a = a_sign ? (~a + 1) : a;  // Absolute value of a
    wire [N-1:0] abs_b = b_sign ? (~b + 1) : b;  // Absolute value of b

    // Addition of absolute values
    wire [N:0] abs_add = abs_a + abs_b;  // (N+1)-bit result of absolute addition

    // Subtraction of absolute values
    wire [N:0] abs_sub_a_b = a - b;  // (N+1)-bit result of a - b
    wire [N:0] abs_sub_b_a = b - a;  // (N+1)-bit result of b - a

    // Flags for determining the operation
    wire same_sign = (a_sign == b_sign);  // a and b have the same sign
    wire a_greater_than_b = (a > b);     // a is greater than b in signed comparison

    // Result assignment logic
    always @(*) begin
        if (same_sign) begin
            // Same sign, add absolute values
            res = abs_add[N-1:0];
            res[N-1] = a_sign;  // Retain the sign bit
        end else begin
            // Different signs, subtract absolute values
            if (a_greater_than_b) begin
                res = abs_sub_a_b[N-1:0];
                res[N-1] = 0;  // Result is positive
            end else begin
                res = abs_sub_b_a[N-1:0];
                res[N-1] = res[N-1];  // Retain the sign bit of the result
            end
        end
    end

    // Assign the result to the output port
    assign c = res;

endmodule