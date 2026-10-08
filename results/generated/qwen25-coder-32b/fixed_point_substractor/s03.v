module fixed_point_subtractor #(
    parameter Q = 8,  // Number of fractional bits
    parameter N = 16  // Total number of bits
) (
    input  [N-1:0] a,  // First N-bit fixed-point input operand
    input  [N-1:0] b,  // Second N-bit fixed-point input operand
    output [N-1:0] c   // N-bit output representing the result of the fixed-point subtraction
);

    // Internal register to store the result
    reg [N-1:0] res;

    // Assign the result to the output port
    assign c = res;

    // Logic to perform fixed-point subtraction
    always @(*) begin
        // Determine the signs of a and b
        wire sign_a = a[N-1];
        wire sign_b = b[N-1];

        // Same sign subtraction
        if (sign_a == sign_b) begin
            // Perform subtraction and keep the sign
            res = sign_a ? (a - b) : (b - a);
            res[N-1] = sign_a;  // Ensure the sign bit is set correctly
        end
        // Different sign subtraction
        else begin
            if (sign_a == 0 && sign_b == 1) begin
                // a is positive, b is negative, add absolute values
                res = a + b;
                res[N-1] = a[N-1];  // Result sign is same as a
            end
            else if (sign_a == 1 && sign_b == 0) begin
                // a is negative, b is positive, add absolute values
                res = a + b;
                res[N-1] = a[N-1];  // Result sign is same as a
            end
        end

        // Handle zero case
        if (res == {N{1'b0}}) begin
            res[N-1] = 1'b0;  // Set sign bit to 0 for zero result
        end
    end

endmodule