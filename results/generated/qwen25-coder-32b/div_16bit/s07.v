module div_16bit (
    input  [15:0] A,   // 16-bit dividend
    input  [7:0]  B,   // 8-bit divisor
    output [15:0] result, // 16-bit quotient
    output [15:0] odd    // 16-bit remainder
);

    // Internal registers to store the current state of the division
    reg [15:0] a_reg; // Copy of the dividend
    reg [7:0]  b_reg;  // Copy of the divisor
    reg [15:0] quotient;
    reg [15:0] remainder;

    // First always block to initialize the registers with input values
    always @(*) begin
        a_reg = A;
        b_reg = B;
    end

    // Second always block to perform the division
    always @(*) begin
        quotient = 0;  // Initialize quotient
        remainder = 0; // Initialize remainder

        // Perform the division bit by bit
        for (integer i = 0; i < 16; i = i + 1) begin
            // Shift the remainder left by 1 and bring in the next bit from the dividend
            remainder = {remainder[14:0], a_reg[15]};
            
            // Compare the higher 8 bits of the remainder with the divisor
            if (remainder[15:8] >= b_reg) begin
                // If remainder is greater or equal, subtract the divisor and set quotient bit to 1
                remainder = remainder - b_reg;
                quotient[15 - i] = 1;
            end else begin
                // Otherwise, set quotient bit to 0
                quotient[15 - i] = 0;
            end
            
            // Shift the dividend left by 1 for the next iteration
            a_reg = a_reg << 1;
        end
    end

    // Assign the final quotient and remainder to the output ports
    assign result = quotient;
    assign odd = remainder;

endmodule