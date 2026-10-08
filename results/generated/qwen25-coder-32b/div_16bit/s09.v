module div_16bit (
    input  [15:0] A,    // 16-bit dividend
    input  [7:0]  B,    // 8-bit divisor
    output [15:0] result, // 16-bit quotient
    output [15:0] odd     // 16-bit remainder
);

reg [15:0] a_reg;       // Register to hold the current dividend
reg [7:0]  b_reg;       // Register to hold the divisor
reg [15:0] quotient;    // Register to hold the quotient
reg [15:0] remainder;   // Register to hold the remainder

// First always block: Update registers a_reg and b_reg with inputs A and B
always @(*) begin
    a_reg = A;
    b_reg = B;
end

// Second always block: Perform the division logic
always @(*) begin
    integer i;
    quotient = 16'b0;    // Initialize quotient to 0
    remainder = 16'b0;   // Initialize remainder to 0

    for (i = 0; i < 16; i = i + 1) begin
        // Shift the remainder left by 1 bit and bring in the next bit from the dividend
        remainder = {remainder[14:0], a_reg[15]};
        
        // Compare the higher 8 bits of the remainder with the divisor
        if (remainder[15:8] >= b_reg) begin
            quotient = {quotient[14:0], 1'b1}; // Set the current quotient bit to 1
            remainder = remainder - b_reg;       // Subtract the divisor from the remainder
        end else begin
            quotient = {quotient[14:0], 1'b0}; // Set the current quotient bit to 0
        end
        
        // Shift the dividend left by 1 bit
        a_reg = a_reg << 1;
    end
    
    // Assign the final quotient and remainder
    result = quotient;
    odd = remainder;
end

endmodule