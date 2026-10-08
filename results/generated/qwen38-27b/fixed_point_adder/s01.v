module fixed_point_adder #(
    parameter integer Q = 8,
    parameter integer N = 16
) (
    input  wire [N-1:0] a,
    input  wire [N-1:0] b,
    output wire [N-1:0] c
);

    // Internal register to store the result
    reg [N-1:0] res;

    // Determine signs
    wire sign_a = a[N-1];
    wire sign_b = b[N-1];

    // Absolute values: if sign bit is 1, take two's complement
    wire [N-1:0] abs_a = sign_a ? (~a + 1) : a;
    wire [N-1:0] abs_b = sign_b ? (~b + 1) : b;

    always @(*) begin
        if (sign_a == sign_b) begin
            // Same sign: add absolute values
            if (sign_a) begin
                // Both negative: result is negative, add absolute values
                res = ~((abs_a + abs_b)) + 1; // two's complement of sum
            end else begin
                // Both positive: result is positive, add absolute values
                res = abs_a + abs_b;
            end
        end else begin
            // Different signs: subtract smaller absolute value from larger
            if (abs_a >= abs_b) begin
                // a >= b in absolute value
                res = abs_a - abs_b;
                // Result sign: if a is positive (sign_a == 0), result is positive; if a is negative, result is negative
                // Since sign_a != sign_b, and abs_a >= abs_b, the result has the sign of a
                res[N-1] = sign_a;
            end else begin
                // b > a in absolute value
                res = abs_b - abs_a;
                // Result has the sign of b
                res[N-1] = sign_b;
            end
        end
    end

    assign c = res;

endmodule