module freq_div (
    input wire CLK_in,  // 100MHz input clock
    input wire RST,     // Reset signal (active high)
    
    output reg CLK_50,  // 50MHz output clock
    output reg CLK_10,  // 10MHz output clock
    output reg CLK_1    // 1MHz output clock
);

    reg [4:0] cnt_10;  // Counter for CLK_10 generation (0 to 4)
    reg [5:0] cnt_100; // Counter for CLK_1 generation (0 to 49)

    always @(posedge CLK_in or posedge RST) begin
        if (RST) begin
            // Reset all outputs and counters
            CLK_50 <= 0;
            CLK_10 <= 0;
            CLK_1  <= 0;
            cnt_10 <= 0;
            cnt_100 <= 0;
        end else begin
            // Generate CLK_50 (50MHz)
            CLK_50 <= ~CLK_50;

            // Generate CLK_10 (10MHz)
            if (cnt_10 == 4) begin
                CLK_10 <= ~CLK_10;
                cnt_10 <= 0;
            end else begin
                cnt_10 <= cnt_10 + 1;
            end

            // Generate CLK_1 (1MHz)
            if (cnt_100 == 49) begin
                CLK_1 <= ~CLK_1;
                cnt_100 <= 0;
            end else begin
                cnt_100 <= cnt_100 + 1;
            end
        end
    end

endmodule