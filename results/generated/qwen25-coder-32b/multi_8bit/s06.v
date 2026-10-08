module multi_8bit (
    input [7:0] A,          // First 8-bit input operand (multiplicand)
    input [7:0] B,          // Second 8-bit input operand (multiplier)
    output [15:0] product   // 16-bit output representing the product (A * B)
);

    // Internal signal to store the intermediate product
    reg [15:0] product_reg;
    // Internal signal to store the shifted multiplicand
    reg [15:0] shifted_A;

    // Initialize the product register to 0
    initial begin
        product_reg = 16'b0;
    end

    // Process to perform multiplication using shift-and-add method
    always @(*) begin
        product_reg = 16'b0;  // Clear the product register
        shifted_A = {8'b0, A};  // Initialize the shifted multiplicand

        // Iterate through each bit of the multiplier (B)
        for (int i = 0; i < 8; i = i + 1) begin
            // If the current bit of B is 1, add the shifted multiplicand to the product
            if (B[i] == 1) begin
                product_reg = product_reg + shifted_A;
            end
            // Shift the multiplicand left by 1 bit for the next iteration
            shifted_A = shifted_A << 1;
        end
    end

    // Assign the final product to the output port
    assign product = product_reg;

endmodule