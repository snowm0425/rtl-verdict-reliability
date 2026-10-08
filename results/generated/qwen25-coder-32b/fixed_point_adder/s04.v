module fixed_point_adder #(
    parameter Q = 4,  // Number of fractional bits (precision)
    parameter N = 8   // Total number of bits, including integer and fractional parts
) (
    input  [N-1:0] a,  // First N-bit fixed-point input operand
    input  [N-1:0] b,  // Second N-bit fixed-point input operand
    output [N-1:0] c   // N-bit output representing the result of the fixed-point addition
);

    // Internal register to store the result
    reg [N-1:0] res;

    // Sign bits of the inputs
    wire a_sign = a[N-1];
    wire b_sign = b[N-1];

    // Absolute values of the inputs
    wire [N-1:0] a_abs = a_sign ? (~a + 1) : a;
    wire [N-1:0] b_abs = b_sign ? (~b + 1) : b;

    // Sum of absolute values
    wire [N:0] sum_abs = a_abs + b_abs;
    wire [N-1:0] sum_abs_n = sum_abs[N-1:0]; // N-bit part of the sum

    // Subtraction results
    wire [N:0] sub_a_b = a_abs - b_abs;
    wire [N-1:0] sub_a_b_n = sub_a_b[N-1:0]; // N-bit part of the subtraction (a - b)
    wire a_greater_b = sub_a_b[N]; // Indicates if a_abs > b_abs

    wire [N:0] sub_b_a = b_abs - a_abs;
    wire [N-1:0] sub_b_a_n = sub_b_a[N-1:0]; // N-bit part of the subtraction (b - a)
    wire b_greater_a = sub_b_a[N]; // Indicates if b_abs > a_abs

    // Result selection logic
    always @(*) begin
        if (a_sign == b_sign) begin
            // Both numbers have the same sign, add their absolute values
            res = {a_sign, sum_abs_n};
        end else begin
            // Numbers have different signs, perform subtraction
            if (a_greater_b) begin
                // a_abs > b_abs, result is positive
                res = {1'b0, sub_a_b_n};
            end else if (b_greater_a) begin
                // b_abs > a_abs, result is negative
                res = {1'b1, sub_b_a_n};
            end else begin
                // a_abs == b_abs, result is zero
                res = {N{1'b0}};
            end
        end
    end

    // Assign the result to the output port
    assign c = res;

endmodule