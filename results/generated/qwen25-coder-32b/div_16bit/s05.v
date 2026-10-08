module div_16bit (
    input  [15:0] A,  // 16-bit dividend
    input  [7:0]  B,  // 8-bit divisor
    output [15:0] result,  // 16-bit quotient
    output [15:0] odd    // 16-bit remainder
);

    reg [15:0] a_reg;  // Register to hold the dividend
    reg [7:0]  b_reg;  // Register to hold the divisor
    reg [15:0] quotient;  // Register to hold the quotient
    reg [15:0] remainder;  // Register to hold the remainder

    // First always block to update the registers with input values
    always @(*) begin
        a_reg = A;
        b_reg = B;
    end

    // Second always block to perform the division operation
    always @(*) begin
        quotient = 16'b0;  // Initialize quotient to 0
        remainder = 16'b0;  // Initialize remainder to 0

        // Perform the division operation
        for (integer i = 0; i < 16; i = i + 1) begin
            // Shift the remainder left by 1 bit and add the next bit of the dividend
            remainder = {remainder[14:0], a_reg[15]};
            a_reg = a_reg << 1;

            // Compare the higher bits of the remainder with the divisor
            if (remainder[15:8] >= b_reg) begin
                quotient[i] = 1'b1;  // Set the quotient bit to 1
                remainder[15:8] = remainder[15:8] - b_reg;  // Subtract the divisor from the remainder
            end else begin
                quotient[i] = 1'b0;  // Set the quotient bit to 0
            end
        end

        // Assign the final quotient and remainder to the output ports
        result = quotient;
        odd = remainder;
    end

endmodule