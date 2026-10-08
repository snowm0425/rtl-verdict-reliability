module fixed_point_adder #(
    parameter Q = 4,
    parameter N = 8
) (
    input  wire [N-1:0] a,
    input  wire [N-1:0] b,
    output wire [N-1:0] c
);

    // Internal register to store the result
    reg [N-1:0] res;

    // Helper signals for absolute value computation
    wire sign_a = a[N-1];
    wire sign_b = b[N-1];

    // Absolute values: if sign bit is 1, negate; else keep as is
    wire [N-1:0] abs_a = sign_a ? (~a + 1'b1) : a;
    wire [N-1:0] abs_b = sign_b ? (~b + 1'b1) : b;

    // Compare absolute values to determine which is larger
    wire abs_a_greater = (abs_a > abs_b);
    wire abs_a_equal   = (abs_a == abs_b);

    // Determine the operation based on signs
    // Case 1: Same signs (both positive or both negative) -> Add absolute values
    // Case 2: Different signs -> Subtract smaller absolute value from larger

    always @* begin
        if (sign_a == sign_b) begin
            // Same sign: add absolute values
            res = abs_a + abs_b;
            // Set the sign bit of the result to match the input signs
            res[N-1] = sign_a;
        end else begin
            // Different signs: subtract smaller absolute value from larger
            if (abs_a_greater) begin
                // |a| > |b|, result = a - b, sign is same as a
                res = abs_a - abs_b;
                res[N-1] = sign_a;
            end else if (abs_a_equal) begin
                // |a| == |b|, result = 0
                res = {N{1'b0}};
            end else begin
                // |b| > |a|, result = b - a, sign is same as b
                res = abs_b - abs_a;
                res[N-1] = sign_b;
            end
        end
    end

    assign c = res;

endmodule