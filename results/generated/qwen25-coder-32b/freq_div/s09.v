module freq_div (
    input wire CLK_in,    // Input clock signal (100 MHz)
    input wire RST,       // Reset signal (active high)
    output reg CLK_50,    // Output clock signal (50 MHz)
    output reg CLK_10,    // Output clock signal (10 MHz)
    output reg CLK_1      // Output clock signal (1 MHz)
);

    // Counter for 10 MHz clock generation
    reg [2:0] cnt_10;  // 3-bit counter (0 to 4)

    // Counter for 1 MHz clock generation
    reg [5:0] cnt_100; // 6-bit counter (0 to 49)

    // Process for generating CLK_50
    always @(posedge CLK_in or posedge RST) begin
        if (RST) begin
            CLK_50 <= 0;
        end else begin
            CLK_50 <= ~CLK_50;  // Toggle CLK_50 on each clock edge
        end
    end

    // Process for generating CLK_10
    always @(posedge CLK_in or posedge RST) begin
        if (RST) begin
            CLK_10 <= 0;
            cnt_10 <= 0;
        end else begin
            if (cnt_10 == 4) begin
                CLK_10 <= ~CLK_10;  // Toggle CLK_10 every 5 clock cycles
                cnt_10 <= 0;
            end else begin
                cnt_10 <= cnt_10 + 1;
            end
        end
    end

    // Process for generating CLK_1
    always @(posedge CLK_in or posedge RST) begin
        if (RST) begin
            CLK_1 <= 0;
            cnt_100 <= 0;
        end else begin
            if (cnt_100 == 49) begin
                CLK_1 <= ~CLK_1;  // Toggle CLK_1 every 50 clock cycles
                cnt_100 <= 0;
            end else begin
                cnt_100 <= cnt_100 + 1;
            end
        end
    end

endmodule