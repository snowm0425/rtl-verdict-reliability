module fixed_point_subtractor #(
    parameter Q = 8,  // Number of fractional bits
    parameter N = 16  // Total number of bits (both integer and fractional)
) (
    input  [N-1:0] a, // First N-bit fixed-point input operand
    input  [N-1:0] b, // Second N-bit fixed-point input operand
    output [N-1:0] c  // N-bit output representing the result of the fixed-point subtraction
);

    // Internal register to store the result
    reg [N-1:0] res;

    // Signals to determine the signs of a and b
    wire a_sign = a[N-1];
    wire b_sign = b[N-1];

    // Absolute values of a and b
    wire [N-1:0] a_abs = a_sign ? (~a + 1) : a;
    wire [N-1:0] b_abs = b_sign ? (~b + 1) : b;

    // Subtract a and b when both have the same sign
    wire [N-1:0] same_sign_sub = a - b;

    // Add absolute values of a and b when they have different signs
    wire [N-1:0] diff_sign_add = a_abs + b_abs;

    // Result selection logic
    always @(*) begin
        if (a_sign == b_sign) begin
            // Same sign subtraction
            res = same_sign_sub;
        end else begin
            // Different sign subtraction
            if (a_sign == 0 && b_sign == 1) begin
                // a is positive, b is negative
                if (a_abs > b_abs) begin
                    res = a_abs - b_abs;
                end else begin
                    res = ~(a_abs - b_abs) + 1; // Negative result
                end
            end else if (a_sign == 1 && b_sign == 0) begin
                // a is negative, b is positive
                if (a_abs > b_abs) begin
                    res = ~(a_abs - b_abs) + 1; // Negative result
                end else begin
                    res = b_abs - a_abs;
                end
            end
        end

        // Handle zero result
        if (res == {N{1'b0}}) begin
            res = {N{1'b0}};
        end
    end

    // Assign the result to the output
    assign c = res;

endmodule