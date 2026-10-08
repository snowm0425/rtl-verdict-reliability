module div_16bit (
    input  [15:0] A,    // 16-bit dividend
    input  [7:0]  B,    // 8-bit divisor
    output [15:0] result, // 16-bit quotient
    output [15:0] odd     // 16-bit remainder
);

    reg [15:0] a_reg; // Register to store the dividend
    reg [7:0]  b_reg;  // Register to store the divisor

    reg [15:0] quotient; // Intermediate quotient
    reg [15:0] remainder; // Intermediate remainder

    // First always block: Update registers with input values
    always @(*) begin
        a_reg = A;
        b_reg = B;
    end

    // Second always block: Perform division logic
    always @(*) begin
        // Initialize quotient and remainder
        quotient = 16'b0;
        remainder = 16'b0;

        // Perform division using bit-by-bit comparison
        for (integer i = 0; i < 16; i = i + 1) begin
            // Shift remainder left by 1 and bring in the next dividend bit
            remainder = {remainder[14:0], a_reg[15]};

            // Compare remainder with divisor
            if (remainder >= b_reg) begin
                quotient = {quotient[14:0], 1'b1};
                remainder = remainder - b_reg;
            end else begin
                quotient = {quotient[14:0], 1'b0};
            end

            // Shift dividend right by 1
            a_reg = a_reg >> 1;
        end

        // Assign final quotient and remainder to output ports
        result = quotient;
        odd = remainder;
    end

endmodule