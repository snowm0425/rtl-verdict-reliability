module freq_divbyfrac (
    input wire clk,
    input wire rst_n,
    output reg clk_div
);

    // Parameters for the frequency division
    localparam MUL2_DIV_CLK = 7;  // Total number of source clock cycles in one period of the divided clock
    localparam HIGH_CLK_CYCLES = 4;  // Number of source clock cycles for the higher period
    localparam LOW_CLK_CYCLES = 3;  // Number of source clock cycles for the lower period

    // Internal signals
    reg [2:0] counter;  // 3-bit counter to count up to MUL2_DIV_CLK
    reg [2:0] phase;  // 2-bit phase register to keep track of the phase for double-edge clocking
    reg clk_div_high;  // Intermediate divided clock signal for higher period
    reg clk_div_low;   // Intermediate divided clock signal for lower period

    // Initialize the output clock signal
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            clk_div <= 0;
            clk_div_high <= 0;
            clk_div_low <= 0;
            counter <= 0;
            phase <= 0;
        end else begin
            // Count the clock cycles
            if (counter == MUL2_DIV_CLK - 1) begin
                counter <= 0;
            end else begin
                counter <= counter + 1;
            end

            // Generate the high and low clock signals based on the counter value
            if (counter < HIGH_CLK_CYCLES) begin
                clk_div_high <= 1;
            end else begin
                clk_div_high <= 0;
            end

            if (counter < LOW_CLK_CYCLES) begin
                clk_div_low <= 1;
            end else begin
                clk_div_low <= 0;
            end

            // Phase shifting for double-edge clocking
            phase <= phase + 1;
            case (phase)
                0: begin
                    clk_div <= clk_div_high;
                end
                1: begin
                    clk_div <= clk_div_high | clk_div_low;
                end
                2: begin
                    clk_div <= clk_div_low;
                end
                default: begin
                    clk_div <= 0;
                end
            endcase
        end
    end

endmodule