module freq_div (
    input CLK_in,      // 100 MHz input clock
    input RST,         // Active high reset signal
    output reg CLK_50, // 50 MHz output clock
    output reg CLK_10, // 10 MHz output clock
    output reg CLK_1   // 1 MHz output clock
);

    // Counters for CLK_10 and CLK_1 generation
    reg [2:0] cnt_10;  // Counter for 10 MHz clock (range 0 to 4)
    reg [5:0] cnt_100; // Counter for 1 MHz clock (range 0 to 49)

    // CLK_50 generation
    always @(posedge CLK_in or posedge RST) begin
        if (RST) begin
            CLK_50 <= 0;
        end else begin
            CLK_50 <= ~CLK_50; // Toggle CLK_50 on each rising edge of CLK_in
        end
    end

    // CLK_10 generation
    always @(posedge CLK_in or posedge RST) begin
        if (RST) begin
            CLK_10 <= 0;
            cnt_10 <= 0;
        end else begin
            if (cnt_10 == 4) begin // Toggle CLK_10 every 5 cycles (100 MHz / 5 = 20 MHz, then toggle every other cycle to get 10 MHz)
                CLK_10 <= ~CLK_10;
                cnt_10 <= 0;
            end else begin
                cnt_10 <= cnt_10 + 1;
            end
        end
    end

    // CLK_1 generation
    always @(posedge CLK_in or posedge RST) begin
        if (RST) begin
            CLK_1 <= 0;
            cnt_100 <= 0;
        end else begin
            if (cnt_100 == 49) begin // Toggle CLK_1 every 50 cycles (100 MHz / 50 = 2 MHz, then toggle every other cycle to get 1 MHz)
                CLK_1 <= ~CLK_1;
                cnt_100 <= 0;
            end else begin
                cnt_100 <= cnt_100 + 1;
            end
        end
    end

endmodule