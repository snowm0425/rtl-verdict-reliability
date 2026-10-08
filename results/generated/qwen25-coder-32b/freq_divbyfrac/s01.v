module freq_divbyfrac (
    input clk,          // Input clock signal
    input rst_n,        // Active low reset signal
    output reg clk_div  // Fractionally divided clock output
);

    // Parameters for fractional division by 3.5
    parameter MUL2_DIV_CLK = 7;  // Total clock cycles in one period
    parameter HIGH_CLK_CYCLES = 4;  // Number of high clock cycles in one period
    parameter LOW_CLK_CYCLES = 3;   // Number of low clock cycles in one period

    // Counters for clock cycles
    reg [2:0] cnt;  // Counter to track clock cycles

    // Intermediate signals for phase-shifting
    reg phase_shifted_clk;
    reg clk_div_high;
    reg clk_div_low;

    // State machine for generating uneven clock periods
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            cnt <= 0;
            clk_div_high <= 0;
            clk_div_low <= 0;
        end else begin
            if (cnt == MUL2_DIV_CLK - 1) begin
                cnt <= 0;
            end else begin
                cnt <= cnt + 1;
            end

            // Generate uneven clock periods
            if (cnt < HIGH_CLK_CYCLES) begin
                clk_div_high <= 1;
                clk_div_low <= 0;
            end else if (cnt < MUL2_DIV_CLK) begin
                clk_div_high <= 0;
                clk_div_low <= 1;
            end
        end
    end

    // Phase-shifting the low clock signal by half a clock period
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            phase_shifted_clk <= 0;
        end else begin
            phase_shifted_clk <= clk_div_low;
        end
    end

    // Generate the final fractional clock output by OR-ing the high and phase-shifted low clocks
    always @(*) begin
        clk_div = clk_div_high | phase_shifted_clk;
    end

endmodule