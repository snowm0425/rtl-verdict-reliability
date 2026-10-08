module fixed_point_subtractor #(
    parameter Q = 8,  // Number of fractional bits
    parameter N = 16  // Total number of bits
)(
    input  [N-1:0] a,  // First N-bit fixed-point input operand
    input  [N-1:0] b,  // Second N-bit fixed-point input operand
    output [N-1:0] c   // N-bit output representing the result of the fixed-point subtraction
);

    // Internal register to store the result
    reg [N-1:0] res;

    // Sign bits of inputs a and b
    wire sign_a = a[N-1];
    wire sign_b = b[N-1];

    // Absolute values of a and b
    wire [N-1:0] abs_a = sign_a ? (~a + 1) : a;
    wire [N-1:0] abs_b = sign_b ? (~b + 1) : b;

    // Result of subtraction
    wire [N:0] diff = {1'b0, abs_a} - {1'b0, abs_b};  // 1 extra bit for overflow

    // Result of addition
    wire [N:0] sum = {1'b0, abs_a} + {1'b0, abs_b};  // 1 extra bit for overflow

    // Sign of the result
    wire sign_res;

    // Magnitude of the result
    wire [N-1:0] magnitude_res;

    // Logic for different cases of subtraction
    always @(*) begin
        if (sign_a == sign_b) begin
            // Same sign subtraction
            res = a - b;
            sign_res = sign_a;
        end else begin
            // Different sign subtraction
            if (sign_a == 1'b0) begin
                // a is positive, b is negative
                if (abs_a >= abs_b) begin
                    sign_res = 1'b0;
                    magnitude_res = sum[N-1:0];
                end else begin
                    sign_res = 1'b1;
                    magnitude_res = sum[N-1:0];
                end
            end else begin
                // a is negative, b is positive
                if (abs_a >= abs_b) begin
                    sign_res = 1'b1;
                    magnitude_res = sum[N-1:0];
                end else begin
                    sign_res = 1'b0;
                    magnitude_res = sum[N-1:0];
                end
            end
            res = {sign_res, magnitude_res};
        end

        // Handling zero case
        if (res == -1) begin
            res = 0;  // If the result is -1 (all bits set), set it to 0
        end
    end

    // Assign the result to the output port
    assign c = res;

endmodule