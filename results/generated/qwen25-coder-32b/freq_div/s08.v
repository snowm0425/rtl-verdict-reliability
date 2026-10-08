module freq_div (
    input wire CLK_in,    // Input clock signal of 100MHz
    input wire RST,       // Reset signal

    output reg CLK_50,    // Output clock signal of 50MHz
    output reg CLK_10,    // Output clock signal of 10MHz
    output reg CLK_1      // Output clock signal of 1MHz
);

    // Counters for CLK_10 and CLK_1 generation
    reg [2:0] cnt_10;     // Counter for 10MHz clock
    reg [5:0] cnt_100;    // Counter for 1MHz clock

    always @(posedge CLK_in or posedge RST) begin
        if (RST) begin
            // Reset all outputs and counters
            CLK_50 <= 0;
            CLK_10 <= 0;
            CLK_1 <= 0;
            cnt_10 <= 0;
            cnt_100 <= 0;
        end else begin
            // Generate CLK_50 by toggling on every rising edge of CLK_in
            CLK_50 <= ~CLK_50;

            // Generate CLK_10
            if (cnt_10 == 4) begin  // 5 cycles of CLK_in = 1 cycle of CLK_10 (100MHz / 5 = 20MHz, but we toggle every 2 cycles)
                CLK_10 <= ~CLK_10;
                cnt_10 <= 0;
            end else begin
                cnt_10 <= cnt_10 + 1;
            end

            // Generate CLK_1
            if (cnt_100 == 49) begin  // 50 cycles of CLK_in = 1 cycle of CLK_1 (100MHz / 50 = 2MHz, but we toggle every 2 cycles)
                CLK_1 <= ~CLK_1;
                cnt_100 <= 0;
            end else begin
                cnt_100 <= cnt_100 + 1;
            end
        end
    end

endmodule