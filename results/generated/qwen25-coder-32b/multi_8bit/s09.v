module multi_8bit (
    input  [7:0] A,        // First 8-bit input operand (multiplicand)
    input  [7:0] B,        // Second 8-bit input operand (multiplier)
    output [15:0] product  // 16-bit output representing the product (A * B)
);

    reg [15:0] acc;  // Accumulator to store the intermediate result

    // Initialize the accumulator to zero
    initial begin
        acc = 16'b0;
    end

    // Process each bit of the multiplier (B)
    always @(*) begin
        acc = 16'b0;  // Reset the accumulator to zero at the start of each multiplication

        // Iterate through each bit of B
        for (int i = 0; i < 8; i = i + 1) begin
            // If the current bit of B is 1, add the shifted multiplicand (A) to the accumulator
            if (B[i] == 1'b1) begin
                acc = acc + (A << i);
            end
        end

        // Assign the final accumulated value to the product output
        product = acc;
    end

endmodule