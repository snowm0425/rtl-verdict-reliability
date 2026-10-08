module div_16bit (
    input  [15:0] A,
    input  [7:0]  B,
    output [15:0] result,
    output [15:0] odd
);

    reg [15:0] a_reg;
    reg [7:0]  b_reg;

    // First always block: assign inputs to registers
    always @(*) begin
        a_reg = A;
        b_reg = B;
    end

    // Second always block: perform combinational division
    always @(*) begin
        reg [15:0] quotient;
        reg [15:0] remainder;
        reg [7:0]  divisor;
        reg [15:0] dividend;
        integer    i;

        // Initialize
        quotient  = 16'b0;
        remainder = 16'b0;
        divisor   = {8'b0, b_reg}; // Extend divisor to 16-bit for comparison
        dividend  = a_reg;

        // Process each bit from MSB to LSB
        for (i = 0; i < 16; i = i + 1) begin
            // Shift remainder left by 1 and bring in next dividend bit
            // We want to process from MSB (bit 15) to LSB (bit 0)
            // At step i, we process dividend bit (15 - i)
            // First, shift remainder left by 1
            remainder = {remainder[14:0], 1'b0};

            // Bring in the next dividend bit (starting from MSB)
            remainder[0] = dividend[15 - i];

            // Compare remainder with divisor
            if (remainder >= divisor) begin
                quotient[15 - i] = 1'b1;
                remainder = remainder - divisor;
            end else begin
                quotient[15 - i] = 1'b0;
                // remainder stays as is
            end
        end

        result  = quotient;
        odd     = remainder;
    end

endmodule