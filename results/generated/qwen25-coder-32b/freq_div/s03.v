module freq_div (
    input wire CLK_in,  // Input clock signal of 100MHz
    input wire RST,     // Reset signal (active high)
    output reg CLK_50,  // Output clock signal of 50MHz
    output reg CLK_10,  // Output clock signal of 10MHz
    output reg CLK_1    // Output clock signal of 1MHz
);

    // Counters for generating CLK_10 and CLK_1
    reg [3:0] cnt_10;   // 4-bit counter for dividing by 10
    reg [5:0] cnt_100;  // 6-bit counter for dividing by 100

    // CLK_50 generation
    always @(posedge CLK_in or posedge RST) begin
        if (RST) begin
            CLK_50 <= 0;
        end else begin
            CLK_50 <= ~CLK_50;  // Toggle CLK_50 on every rising edge of CLK_in
        end
    end

    // CLK_10 generation
    always @(posedge CLK_in or posedge RST) begin
        if (RST) begin
            CLK_10 <= 0;
            cnt_10 <= 0;
        end else begin
            if (cnt_10 == 4) begin  // Divide by 10 (5 cycles to toggle)
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
            if (cnt_100 == 49) begin  // Divide by 100 (50 cycles to toggle)
                CLK_1 <= ~CLK_1;
                cnt_100 <= 0;
            end else begin
                cnt_100 <= cnt_100 + 1;
            end
        end
    end

endmodule