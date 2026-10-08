module div_16bit (
    input  wire  [15:0] A,       // 16-bit dividend
    input  wire  [7:0]  B,       // 8-bit divisor
    output wire  [15:0] result,  // 16-bit quotient
    output wire  [15:0] odd      // 16-bit remainder
);

    reg [15:0] a_reg;            // Register to store the dividend
    reg [7:0]  b_reg;            // Register to store the divisor
    reg [15:0] quotient;         // Register to store the quotient
    reg [15:0] remainder;        // Register to store the remainder
    reg [15:0] temp_remainder;   // Temporary register to store the remainder during the division process

    // First always block: Update the dividend and divisor registers
    always @(*) begin
        a_reg = A;
        b_reg = B;
    end

    // Second always block: Perform the division logic
    always @(*) begin
        temp_remainder = {a_reg[15:8], 8'b0}; // Initialize with the higher 8 bits of the dividend
        quotient = 16'b0;                     // Initialize quotient to 0

        // Perform the division bit by bit
        for (integer i = 0; i < 16; i = i + 1) begin
            // Compare the current remainder with the divisor
            if (temp_remainder >= b_reg) begin
                quotient[i] = 1'b1;             // Set the current quotient bit to 1
                temp_remainder = temp_remainder - b_reg; // Subtract the divisor from the remainder
            end else begin
                quotient[i] = 1'b0;             // Set the current quotient bit to 0
            end

            // Shift the remainder left by 1 bit and bring in the next dividend bit
            temp_remainder = {temp_remainder[14:0], a_reg[15-i-1]};
        end

        // The final remainder is stored in temp_remainder, but we need to shift it left by 8 bits
        remainder = {temp_remainder[7:0], 8'b0};
    end

    // Assign the final quotient and remainder to the output ports
    assign result = quotient;
    assign odd = remainder;

endmodule