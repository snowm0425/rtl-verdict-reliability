module freq_divbyfrac (
    input clk,      // Input clock signal
    input rst_n,    // Active low reset signal
    output reg clk_div  // Fractionally divided clock output
);

    // Constants for the fractional division
    localparam MUL2_DIV_CLK = 7; // Total number of clock cycles to achieve 3.5 division
    localparam HALF_CLK_CYCLES = MUL2_DIV_CLK / 2; // Half of the total clock cycles

    // Registers to count clock cycles
    reg [3:0] count; // Counter to track the number of clock cycles

    // Intermediate signals for phase-shifting
    reg clk_div_early;
    reg clk_div_late;

    // Counter to track the number of cycles for each phase
    reg [2:0] phase_count;

    // State machine to manage the clock division
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            count <= 0;
            phase_count <= 0;
            clk_div <= 0;
            clk_div_early <= 0;
            clk_div_late <= 0;
        end else begin
            // Increment the count
            count <= count + 1;

            // Generate the intermediate clocks
            if (count < HALF_CLK_CYCLES) begin
                // First half of the cycle (4 cycles)
                clk_div_early <= (count == 0) ? 1 : clk_div_early;
                clk_div_late <= 0;
            end else if (count < MUL2_DIV_CLK) begin
                // Second half of the cycle (3 cycles)
                clk_div_late <= (count == HALF_CLK_CYCLES) ? 1 : clk_div_late;
                clk_div_early <= 0;
            end else begin
                // Reset the counter after a complete cycle
                count <= 0;
            end

            // Phase-shifting the clocks
            if (count == MUL2_DIV_CLK - 1) begin
                // Ensure the clocks are reset after a full cycle
                clk_div_early <= 0;
                clk_div_late <= 0;
            end

            // Generate the final output clock
            clk_div <= clk_div_early | clk_div_late;

            // Increment the phase count
            if (count == 0) begin
                phase_count <= phase_count + 1;
            end
        end
    end

endmodule