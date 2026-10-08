module fixed_point_adder #(
    parameter Q = 8,  // Number of fractional bits
    parameter N = 16  // Total number of bits (including integer and fractional parts)
)(
    input  [N-1:0] a, // First N-bit fixed-point input operand
    input  [N-1:0] b, // Second N-bit fixed-point input operand
    output [N-1:0] c  // N-bit output representing the result of the fixed-point addition
);

    // Internal signals
    wire [N:0]   add_res; // Result of adding a and b (one extra bit for overflow detection)
    wire [N:0]   sub_res; // Result of subtracting a and b (one extra bit for overflow detection)
    wire         sign_a;  // Sign bit of a
    wire         sign_b;  // Sign bit of b
    wire         sign_res;// Sign bit of the result
    wire [N-1:0] abs_a;   // Absolute value of a
    wire [N-1:0] abs_b;   // Absolute value of b
    wire [N-1:0] res;     // Final result after processing

    // Assign sign bits
    assign sign_a = a[N-1];
    assign sign_b = b[N-1];

    // Calculate absolute values
    assign abs_a = sign_a ? (~a + 1) : a;
    assign abs_b = sign_b ? (~b + 1) : b;

    // Addition of absolute values
    assign add_res = abs_a + abs_b;

    // Subtraction of absolute values (a - b)
    assign sub_res = abs_a - abs_b;

    // Determine the sign of the result based on the MSBs of a and b
    always @(*) begin
        if (sign_a == sign_b) begin
            // Both a and b have the same sign
            res = add_res[N-1:0]; // Take the lower N bits
            sign_res = sign_a;     // Result sign is the same as a and b
        end else begin
            // a and b have different signs
            if (abs_a >= abs_b) begin
                res = sub_res[N-1:0]; // Take the lower N bits
                sign_res = 0;         // Result is positive
            end else begin
                res = (~sub_res[N-1:0] + 1); // Two's complement of sub_res
                sign_res = 1;                  // Result is negative
            end
        end
    end

    // Handle overflow by ensuring the sign bit is consistent
    assign c = sign_res ? ({1'b1, res} >> 1) : ({1'b0, res} >> 1);

endmodule