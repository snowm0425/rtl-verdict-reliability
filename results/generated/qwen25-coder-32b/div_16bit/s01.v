module div_16bit (
    input wire [15:0] A,          // 16-bit dividend
    input wire [7:0] B,           // 8-bit divisor
    output wire [15:0] result,    // 16-bit quotient
    output wire [15:0] odd        // 16-bit remainder
);

    reg [15:0] a_reg;             // Register to store the dividend
    reg [7:0] b_reg;              // Register to store the divisor
    reg [15:0] quotient;          // Register to store the quotient
    reg [15:0] remainder;         // Register to store the remainder

    // First always block to update a_reg and b_reg
    always @(*) begin
        a_reg = A;
        b_reg = B;
    end

    // Second always block to perform the division
    always @(*) begin
        quotient = 16'b0;         // Initialize quotient to 0
        remainder = 16'b0;        // Initialize remainder to 0

        for (integer i = 0; i < 16; i = i + 1) begin
            // Shift remainder left by 1 and add the next bit of a_reg
            remainder = {remainder[14:0], a_reg[15]};
            a_reg = a_reg << 1;

            // Compare the higher 8 bits of remainder with b_reg
            if (remainder[15:8] >= b_reg) begin
                remainder[15:8] = remainder[15:8] - b_reg;
                quotient[15-i] = 1'b1;
            end else begin
                quotient[15-i] = 1'b0;
            end
        end
    end

    // Assign the final quotient and remainder to the output ports
    assign result = quotient;
    assign odd = remainder;

endmodule