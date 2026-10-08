module fixed_point_adder #(
    parameter Q = 4,  // Number of fractional bits
    parameter N = 8   // Total number of bits
)(
    input  [N-1:0] a,  // First fixed-point input operand
    input  [N-1:0] b,  // Second fixed-point input operand
    output [N-1:0] c   // Output result of the fixed-point addition
);

    // Internal register to store the result
    reg [N-1:0] res;

    // Signals for determining the signs and absolute values
    wire sign_a = a[N-1];
    wire sign_b = b[N-1];
    wire [N-1:0] abs_a = sign_a ? (~a + 1) : a;
    wire [N-1:0] abs_b = sign_b ? (~b + 1) : b;

    // Signals for determining the larger absolute value
    wire a_greater_b = (abs_a > abs_b);

    // Adder/Subtractor logic
    always @(*) begin
        if (sign_a == sign_b) begin
            // Both numbers have the same sign, add their absolute values
            res = abs_a + abs_b;
            res[N-1] = sign_a;  // Set the sign bit
        end else begin
            // Numbers have different signs, perform subtraction
            if (a_greater_b) begin
                res = abs_a - abs_b;
                res[N-1] = 0;  // Result is positive
            end else begin
                res = abs_b - abs_a;
                res[N-1] = res == 0 ? 0 : 1;  // Result is zero or negative
            end
        end
    end

    // Assign the result to the output port
    assign c = res;

endmodule