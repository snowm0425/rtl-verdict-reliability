module div_16bit (
    input wire [15:0] A,    // 16-bit dividend
    input wire [7:0] B,     // 8-bit divisor
    output wire [15:0] result, // 16-bit quotient
    output wire [15:0] odd     // 16-bit remainder
);

    // Registers to hold the current state of the dividend and divisor
    reg [15:0] a_reg;
    reg [7:0] b_reg;

    // Intermediate signals
    reg [15:0] quotient;
    reg [15:0] remainder;

    // First always block: update registers a_reg and b_reg on any change in A or B
    always @(*) begin
        a_reg = A;
        b_reg = B;
    end

    // Second always block: perform the division logic
    always @(*) begin
        // Initialize quotient and remainder
        quotient = 16'b0;
        remainder = 16'b0;

        // Perform the division process
        for (integer i = 0; i < 16; i = i + 1) begin
            // Shift the remainder left by 1 bit and add the next bit of the dividend
            remainder = {remainder[14:0], a_reg[15]};

            // Compare the higher bits of the remainder with the divisor
            if (remainder[15:8] >= b_reg) begin
                // If the remainder is greater or equal to the divisor, subtract the divisor
                remainder[15:8] = remainder[15:8] - b_reg;
                // Set the corresponding bit in the quotient to 1
                quotient = quotient | (16'b1 << (15 - i));
            end

            // Shift the dividend left by 1 bit
            a_reg = a_reg << 1;
        end
    end

    // Assign the final quotient and remainder to the output ports
    assign result = quotient;
    assign odd = remainder;

endmodule