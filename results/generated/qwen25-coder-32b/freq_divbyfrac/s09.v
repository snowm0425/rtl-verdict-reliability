module freq_divbyfrac (
    input wire clk,
    input wire rst_n,
    output reg clk_div
);

    // Parameters for fractional division
    localparam MUL2_DIV_CLK = 7; // Total clock cycles for one full cycle of division
    localparam HIGH_COUNT = 4;   // Number of source clock cycles for the longer period
    localparam LOW_COUNT = 3;    // Number of source clock cycles for the shorter period

    // Counters and state variables
    reg [3:0] count;            // Counter to track clock cycles
    reg clk_div_int;            // Intermediate clock signal
    reg clk_div_delay;          // Delayed version of the intermediate clock signal

    // State machine to control the clock division
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            count <= 0;
            clk_div_int <= 0;
        end else begin
            if (count == MUL2_DIV_CLK - 1) begin
                count <= 0;
            end else begin
                count <= count + 1;
            end

            // Generate intermediate clock signal with two different periods
            if (count < HIGH_COUNT) begin
                clk_div_int <= 1;
            end else begin
                clk_div_int <= 0;
            end
        end
    end

    // Generate delayed version of the intermediate clock signal
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            clk_div_delay <= 0;
        end else begin
            clk_div_delay <= clk_div_int;
        end
    end

    // OR the intermediate clock with its delayed version to produce the final output
    assign clk_div = clk_div_int | clk_div_delay;

endmodule