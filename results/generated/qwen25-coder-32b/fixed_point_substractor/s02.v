module fixed_point_subtractor #(
    parameter Q = 4,  // Number of fractional bits
    parameter N = 8   // Total number of bits (integer + fractional)
)(
    input  [N-1:0] a,  // First N-bit fixed-point input operand
    input  [N-1:0] b,  // Second N-bit fixed-point input operand
    output [N-1:0] c   // N-bit output representing the result of the fixed-point subtraction
);

    // Internal register to store the result
    reg [N-1:0] res;

    // Calculate the absolute values of a and b
    wire [N-1:0] abs_a = (a[N-1]) ? (~a + 1) : a;
    wire [N-1:0] abs_b = (b[N-1]) ? (~b + 1) : b;

    // Determine the sign of the result
    reg sign_res;

    // Perform the subtraction based on the signs of a and b
    always @(*) begin
        if (a[N-1] == b[N-1]) begin
            // Same sign subtraction
            res = a - b;
            sign_res = a[N-1];
        end else begin
            // Different sign subtraction
            if (a[N-1] == 1'b0) begin
                // a is positive, b is negative
                res = abs_a + abs_b;
                sign_res = (abs_a >= abs_b) ? 1'b0 : 1'b1;
            end else begin
                // a is negative, b is positive
                res = abs_a + abs_b;
                sign_res = (abs_a >= abs_b) ? 1'b1 : 1'b0;
            end
        end

        // Handle the case when the result is zero
        if (res == 0) begin
            sign_res = 1'b0;
        end
    end

    // Assign the result to the output port
    assign c = {sign_res, res[N-2:0]};

endmodule