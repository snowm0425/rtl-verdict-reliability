module fixed_point_subtractor #(
    parameter Q = 8,  // Number of fractional bits
    parameter N = 16  // Total number of bits
)(
    input  [N-1:0] a,  // First N-bit fixed-point input operand
    input  [N-1:0] b,  // Second N-bit fixed-point input operand
    output [N-1:0] c   // N-bit output representing the result of the fixed-point subtraction
);

    // Internal register to store the result of the subtraction operation
    reg [N-1:0] res;

    // Internal wires for sign and absolute value calculations
    wire sign_a = a[N-1];
    wire sign_b = b[N-1];
    wire [N-1:0] abs_a = sign_a ? (~a + 1) : a;
    wire [N-1:0] abs_b = sign_b ? (~b + 1) : b;

    // Internal wire for the sum of absolute values
    wire [N:0] sum_abs = abs_a + abs_b;

    always @(*) begin
        if (sign_a == sign_b) begin
            // Same sign subtraction
            res = a - b;
        end else begin
            // Different sign subtraction
            if (sum_abs[N-1] == 0) begin
                // Result is positive
                res = sum_abs[N-2:0];
            end else begin
                // Result is negative
                res = {1'b1, ~sum_abs[N-2:0] + 1};
            end
        end

        // Handle zero case explicitly
        if (res == -1'b1) begin
            res = 0;
        end
    end

    // Assign the result to the output
    assign c = res;

endmodule