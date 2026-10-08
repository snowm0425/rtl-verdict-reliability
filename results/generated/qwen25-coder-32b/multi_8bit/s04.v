module multi_8bit (
    input  [7:0] A,          // First 8-bit input operand (multiplicand)
    input  [7:0] B,          // Second 8-bit input operand (multiplier)
    output [15:0] product    // 16-bit output representing the product (A * B)
);

    reg [15:0] temp_product; // Temporary register to store the product during computation

    // Initialize the product to zero
    initial begin
        temp_product = 16'b0;
    end

    // Shift and Add process
    always @(*) begin
        temp_product = 16'b0; // Reset the product to zero at the start of each multiplication

        for (int i = 0; i < 8; i = i + 1) begin
            if (B[i] == 1'b1) begin
                temp_product = temp_product + (A << i); // Add shifted multiplicand if the bit is set
            end
        end
    end

    // Assign the final product to the output port
    assign product = temp_product;

endmodule