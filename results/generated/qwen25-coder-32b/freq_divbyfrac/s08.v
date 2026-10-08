module freq_divbyfrac (
    input clk,        // Input clock signal
    input rst_n,      // Active low reset signal
    output reg clk_div  // Fractionally divided clock output
);

    // Constants for the divider
    localparam MUL2_DIV_CLK = 7; // Total cycles for 3.5x division

    // Counters and registers
    reg [2:0] count; // Counter to track clock cycles
    reg clk_div_int; // Intermediate divided clock signal
    reg clk_div_delay; // Delayed version of the divided clock signal

    // State machine to generate intermediate clock signal
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            count <= 3'b000; // Reset count
            clk_div_int <= 1'b0; // Reset intermediate clock signal
        end else begin
            if (count == 3'b100) begin // After 4 cycles
                clk_div_int <= 1'b1; // High for the next cycle
                count <= count + 1;
            end else if (count == 3'b111) begin // After 7 cycles
                clk_div_int <= 1'b0; // Low for the next cycle
                count <= 3'b000; // Reset count
            end else if (count == 3'b011) begin // After 3 cycles
                clk_div_int <= 1'b1; // High for the next cycle
                count <= count + 1;
            end else begin
                clk_div_int <= 1'b0; // Low for the next cycle
                count <= count + 1;
            end
        end
    end

    // Generate delayed version of the intermediate clock signal
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            clk_div_delay <= 1'b0; // Reset delayed clock signal
        end else begin
            clk_div_delay <= clk_div_int; // Delay the intermediate clock signal
        end
    end

    // Phase-shifting and OR-ing to generate the final fractional divided clock
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            clk_div <= 1'b0; // Reset final clock signal
        end else begin
            clk_div <= clk_div_int | clk_div_delay; // OR the intermediate and delayed signals
        end
    end

endmodule