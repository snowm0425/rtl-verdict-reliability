module fixed_point_subtractor #(
    parameter Q = 8,  // Number of fractional bits
    parameter N = 16  // Total number of bits
) (
    input  [N-1:0] a,  // First N-bit fixed-point input operand
    input  [N-1:0] b,  // Second N-bit fixed-point input operand
    output [N-1:0] c   // N-bit output representing the result of the fixed-point subtraction
);

    reg [N-1:0] res;  // Internal register to store the result

    // Wire declarations for easier readability
    wire [N-1:0] a_abs;  // Absolute value of a
    wire [N-1:0] b_abs;  // Absolute value of b
    wire         a_sign; // Sign of a
    wire         b_sign; // Sign of b

    // Extract sign bits
    assign a_sign = a[N-1];
    assign b_sign = b[N-1];

    // Calculate absolute values
    assign a_abs = a_sign ? (~a + 1) : a;
    assign b_abs = b_sign ? (~b + 1) : b;

    // Same sign subtraction
    always @(*) begin
        if (a_sign == b_sign) begin
            res = a - b;
        end else begin
            // Different sign subtraction
            if (a_sign == 0 && b_sign == 1) begin
                // a is positive, b is negative
                if (a_abs >= b_abs) begin
                    res = a_abs - b_abs;
                end else begin
                    res = ~(a_abs - b_abs) + 1; // Result is negative
                end
            end else if (a_sign == 1 && b_sign == 0) begin
                // a is negative, b is positive
                if (a_abs >= b_abs) begin
                    res = ~(a_abs - b_abs) + 1; // Result is negative
                end else begin
                    res = b_abs - a_abs;
                end
            end
        end
    end

    // Handle zero result explicitly
    assign c = (res == 0) ? {N{1'b0}} : res;

endmodule