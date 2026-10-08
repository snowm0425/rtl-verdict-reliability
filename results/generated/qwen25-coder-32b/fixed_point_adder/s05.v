module fixed_point_adder #(
    parameter N = 8,  // Total number of bits
    parameter Q = 4   // Number of fractional bits
)(
    input  [N-1:0] a,  // First N-bit fixed-point input operand
    input  [N-1:0] b,  // Second N-bit fixed-point input operand
    output [N-1:0] c   // N-bit output representing the result of the fixed-point addition
);

    // Internal registers
    reg [N-1:0] res;  // Result of the addition or subtraction

    // Calculate the absolute values
    wire [N-1:0] abs_a = (a[N-1]) ? (~a + 1) : a;
    wire [N-1:0] abs_b = (b[N-1]) ? (~b + 1) : b;

    // Determine if the signs of a and b are the same
    wire same_sign = (a[N-1] == b[N-1]);

    // Determine if a is greater than b based on absolute values
    wire a_gt_b = (abs_a > abs_b);

    // Perform addition or subtraction based on the signs
    always @(*) begin
        if (same_sign) begin
            // Same sign, perform absolute value addition
            res = abs_a + abs_b;
            // Set the sign bit of the result to match the input operands
            res[N-1] = a[N-1];
        end else begin
            // Different signs, perform absolute value subtraction
            if (a_gt_b) begin
                res = abs_a - abs_b;
                // Result is positive
                res[N-1] = 0;
            end else begin
                res = abs_b - abs_a;
                // Result is negative if not zero
                res[N-1] = (res == 0) ? 0 : 1;
            end
        end
    end

    // Handle overflow by ensuring the result fits within N bits
    assign c = res;

endmodule