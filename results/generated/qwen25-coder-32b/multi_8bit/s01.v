module multi_8bit (
    input [7:0] A,          // First 8-bit input operand (multiplicand)
    input [7:0] B,          // Second 8-bit input operand (multiplier)
    output [15:0] product   // 16-bit output representing the product of A and B
);

    reg [15:0] product_reg; // Internal register to accumulate the product

    // Initialize the product register to zero
    initial begin
        product_reg = 16'b0;
    end

    // Process each bit of the multiplier (B)
    always @(*) begin
        product_reg = 16'b0; // Reset the product register at the start of each multiplication

        for (integer i = 0; i < 8; i = i + 1) begin
            // If the current bit of B is 1, add the shifted multiplicand A to the product
            if (B[i] == 1'b1) begin
                product_reg = product_reg + (A << i);
            end
        end
    end

    // Assign the final product to the output port
    assign product = product_reg;

endmodule