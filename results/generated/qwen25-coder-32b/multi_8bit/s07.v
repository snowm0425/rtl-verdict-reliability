module multi_8bit (
    input [7:0] A,
    input [7:0] B,
    output [15:0] product
);

    // Internal signal to store the product
    reg [15:0] product_reg;

    // Initialize product_reg to 0 at the beginning of multiplication
    initial begin
        product_reg = 16'b0;
    end

    // Generate always block to perform the multiplication
    always @(*) begin
        product_reg = 16'b0; // Initialize product to 0 at the start of each multiplication

        // Loop through each bit of the multiplier B
        for (integer i = 0; i < 8; i = i + 1) begin
            // Check if the current bit of B is set (1)
            if (B[i] == 1'b1) begin
                // Add the shifted multiplicand A to the product
                product_reg = product_reg + (A << i);
            end
        end
    end

    // Assign the final product to the output port
    assign product = product_reg;

endmodule