module fixed_point_subtractor #(
    parameter Q = 8,  // Number of fractional bits
    parameter N = 16  // Total number of bits (integer + fractional)
)(
    input wire [N-1:0] a,  // First N-bit fixed-point input operand
    input wire [N-1:0] b,  // Second N-bit fixed-point input operand
    output wire [N-1:0] c  // N-bit output representing the result of the fixed-point subtraction
);

    // Internal register to store the result of the subtraction operation
    reg [N-1:0] res;

    // Intermediate signals
    wire [N-1:0] abs_a;
    wire [N-1:0] abs_b;
    wire [N:0]   sum_abs;  // To handle overflow
    wire         sign_a;
    wire         sign_b;
    wire         same_sign;
    wire [N-1:0] signed_subtract;

    // Extract the sign bits
    assign sign_a = a[N-1];
    assign sign_b = b[N-1];

    // Check if the signs of a and b are the same
    assign same_sign = (sign_a == sign_b);

    // Absolute values of a and b
    assign abs_a = sign_a ? (~a + 1) : a;
    assign abs_b = sign_b ? (~b + 1) : b;

    // Signed subtraction (a - b)
    assign signed_subtract = a - b;

    // Sum of absolute values (used when signs are different)
    assign sum_abs = abs_a + abs_b;

    // Determine the result based on the signs of a and b
    always @(*) begin
        if (same_sign) begin
            // Same sign, perform normal subtraction
            res = signed_subtract;
        end else begin
            // Different signs, add absolute values and determine the sign
            if (abs_a >= abs_b) begin
                res = abs_a - abs_b;
                res[N-1] = sign_a;  // Result sign is the same as a's sign
            end else begin
                res = abs_b - abs_a;
                res[N-1] = sign_b;  // Result sign is the same as b's sign
            end
        end

        // Handle the zero case explicitly
        if (res == {N{1'b0}}) begin
            res[N-1] = 1'b0;  // Set sign bit to 0 for zero
        end
    end

    // Assign the result to the output
    assign c = res;

endmodule