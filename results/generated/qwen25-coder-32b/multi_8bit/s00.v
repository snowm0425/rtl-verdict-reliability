module multi_8bit (
    input  [7:0] A,          // First 8-bit input operand (multiplicand)
    input  [7:0] B,          // Second 8-bit input operand (multiplier)
    output [15:0] product    // 16-bit output representing the product
);

    // Temporary register to hold the intermediate product
    reg [15:0] temp_product;

    // Initialize the product to zero
    initial begin
        temp_product = 16'b0;
    end

    // Shift-and-add process
    always @(*) begin
        temp_product = 16'b0; // Reset the product to zero at the start of each calculation
        for (int i = 0; i < 8; i = i + 1) begin
            if (B[i] == 1) begin
                temp_product = temp_product + (A << i); // Add A shifted left by i bits if B[i] is 1
            end
        end
    end

    // Assign the final product
    assign product = temp_product;

endmodule