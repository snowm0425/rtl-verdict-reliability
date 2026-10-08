module multi_8bit (
    input  [7:0] A,        // First 8-bit input operand (multiplicand)
    input  [7:0] B,        // Second 8-bit input operand (multiplier)
    output [15:0] product  // 16-bit output representing the product (A * B)
);

    reg [15:0] product_reg;  // Internal register to accumulate the product
    reg [15:0] multiplicand; // Register to hold the multiplicand (A) during processing
    reg [7:0]  multiplier;  // Register to hold the multiplier (B) during processing

    integer i;  // Loop variable

    // Initialize the product register and multiplier
    always @(*) begin
        product_reg = 16'b0;  // Clear the product register
        multiplicand = {8'b0, A};  // Load the multiplicand with A, shifted left by 8 bits
        multiplier = B;  // Load the multiplier with B

        // Perform shift-and-add for each bit of the multiplier
        for (i = 0; i < 8; i = i + 1) begin
            if (multiplier[0] == 1'b1) begin
                product_reg = product_reg + multiplicand;  // Add multiplicand if the current bit of multiplier is 1
            end
            multiplicand = multiplicand << 1;  // Shift the multiplicand left by 1 bit
            multiplier = multiplier >> 1;  // Shift the multiplier right by 1 bit
        end
    end

    // Assign the final product to the output port
    assign product = product_reg;

endmodule