module div_16bit (
    input wire [15:0] A,    // 16-bit dividend
    input wire [7:0] B,     // 8-bit divisor
    output wire [15:0] result, // 16-bit quotient
    output wire [15:0] odd   // 16-bit remainder
);

    reg [15:0] a_reg;       // Register to hold the dividend
    reg [7:0] b_reg;        // Register to hold the divisor
    reg [15:0] quotient;    // Register to hold the quotient
    reg [15:0] remainder;   // Register to hold the remainder

    // First always block: Combinational assignment of inputs to registers
    always @(*) begin
        a_reg = A;
        b_reg = B;
    end

    // Second always block: Combinational logic for division
    always @(*) begin
        // Initialize quotient and remainder
        quotient = 16'b0;
        remainder = 16'b0;

        // Perform the division process
        for (integer i = 15; i >= 0; i = i - 1) begin
            // Shift remainder left by 1 and bring in the next bit of the dividend
            remainder = {remainder[14:0], a_reg[i]};

            // Compare remainder with divisor
            if (remainder >= b_reg) begin
                quotient[i] = 1'b1;  // Set the current quotient bit to 1
                remainder = remainder - b_reg;  // Subtract divisor from remainder
            end else begin
                quotient[i] = 1'b0;  // Set the current quotient bit to 0
            end
        end
    end

    // Assign outputs
    assign result = quotient;
    assign odd = remainder;

endmodule