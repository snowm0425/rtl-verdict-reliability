module freq_divbyfrac (
    input clk,      // Input clock signal
    input rst_n,    // Active low reset signal
    output reg clk_div  // Fractionally divided clock output
);

    // Parameters for 3.5x division
    localparam MUL2_DIV_CLK = 7;  // Total cycles to achieve 3.5x division
    localparam PHASE_SHIFT_CYCLES = 1;  // Cycles to phase shift

    // Internal signals
    reg [2:0] counter;  // Counter to track clock cycles
    reg [1:0] phase;  // Phase selector
    reg clk_4, clk_3;  // Intermediate clocks with different periods

    // Initialize counters and phase selector
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            counter <= 3'b000;
            phase <= 2'b00;
            clk_4 <= 1'b0;
            clk_3 <= 1'b0;
            clk_div <= 1'b0;
        end else begin
            // Increment counter
            counter <= counter + 1'b1;

            // Generate 4-clock and 3-clock cycles
            if (counter < 4) begin
                clk_4 <= ~clk_4;
                clk_3 <= 1'b0;
            end else if (counter < 7) begin
                clk_3 <= ~clk_3;
                clk_4 <= 1'b0;
            end else begin
                clk_4 <= 1'b0;
                clk_3 <= 1'b0;
                counter <= 3'b000;  // Reset counter
            end

            // Phase shifting logic
            case (phase)
                2'b00: begin
                    if (clk_4) phase <= 2'b01;
                end
                2'b01: begin
                    if (clk_3) phase <= 2'b10;
                end
                2'b10: begin
                    if (clk_4) phase <= 2'b11;
                end
                2'b11: begin
                    if (clk_3) phase <= 2'b00;
                end
            endcase

            // Generate final divided clock
            clk_div <= (phase == 2'b00) ? clk_4 : clk_3;
        end
    end

endmodule