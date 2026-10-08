module div_16bit (
    input  [15:0] A,    // 16-bit dividend
    input  [7:0]  B,    // 8-bit divisor
    output [15:0] result, // 16-bit quotient
    output [15:0] odd     // 16-bit remainder
);

    reg [15:0] a_reg;  // Register to store the dividend
    reg [7:0]  b_reg;   // Register to store the divisor
    reg [15:0] quotient; // Register to store the quotient
    reg [15:0] remainder; // Register to store the remainder

    // First always block: update the registers with input values
    always @(*) begin
        a_reg = A;
        b_reg = B;
    end

    // Second always block: perform the division
    always @(*) begin
        quotient = 16'b0;
        remainder = {a_reg[15:8], 8'b0}; // Initialize remainder with the higher 8 bits of A

        // Perform the division process
        for (int i = 0; i < 16; i = i + 1) begin
            if (remainder >= b_reg) begin
                quotient[i] = 1;
                remainder = remainder - b_reg;
            end else begin
                quotient[i] = 0;
            end

            // Shift the remainder left by 1 bit and add the next bit of the dividend
            if (i < 15) begin
                remainder = {remainder[14:0], a_reg[15-i-1]};
            end
        end

        // Assign the final quotient and remainder to the output ports
        result = quotient;
        odd = remainder;
    end

endmodule