module freq_divbyfrac (
    input wire clk,
    input wire rst_n,
    output reg clk_div
);

    // Constants for 3.5x division
    localparam MUL2_DIV_CLK = 7; // Total clock cycles in one period
    localparam HIGH_CLK_CYCLES = 4; // Number of high cycles in the first part of the period
    localparam LOW_CLK_CYCLES = 3; // Number of low cycles in the second part of the period

    // Counters
    reg [2:0] counter; // 3-bit counter to count up to 7

    // Intermediate signals
    reg clk_high;
    reg clk_low;

    // State machine to generate intermediate clocks
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            counter <= 0;
            clk_high <= 0;
            clk_low <= 0;
        end else begin
            if (counter == MUL2_DIV_CLK - 1) begin
                counter <= 0;
            end else begin
                counter <= counter + 1;
            end

            // Generate clk_high for 4 cycles and clk_low for 3 cycles
            if (counter < HIGH_CLK_CYCLES) begin
                clk_high <= 1;
                clk_low <= 0;
            end else begin
                clk_high <= 0;
                clk_low <= 1;
            end
        end
    end

    // Phase shift the intermediate clocks
    reg clk_high_shifted;
    reg clk_low_shifted;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            clk_high_shifted <= 0;
            clk_low_shifted <= 0;
        end else begin
            // Shift clk_high by half a period (one clock cycle)
            clk_high_shifted <= clk_high;

            // Shift clk_low by half a period (one clock cycle)
            clk_low_shifted <= clk_low;
        end
    end

    // Combine the phase-shifted clocks to create the final output
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            clk_div <= 0;
        end else begin
            // OR the phase-shifted clocks to achieve the fractional division
            clk_div <= clk_high_shifted | clk_low_shifted;
        end
    end

endmodule