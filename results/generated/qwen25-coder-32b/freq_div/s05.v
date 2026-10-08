module freq_div (
    input wire CLK_in,
    input wire RST,
    output reg CLK_50,
    output reg CLK_10,
    output reg CLK_1
);

    // Counters for CLK_10 and CLK_1 generation
    reg [2:0] cnt_10;  // Counter for 10MHz clock (0 to 4)
    reg [5:0] cnt_100; // Counter for 1MHz clock (0 to 49)

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
        end else if (cnt_10 == 4) begin
            CLK_10 <= ~CLK_10; // Toggle CLK_10
            cnt_10 <= 0;       // Reset counter
        end else begin
            cnt_10 <= cnt_10 + 1; // Increment counter
        end
    end

    // CLK_1 generation
    always @(posedge CLK_in or posedge RST) begin
        if (RST) begin
            CLK_1 <= 0;
            cnt_100 <= 0;
        end else if (cnt_100 == 49) begin
            CLK_1 <= ~CLK_1; // Toggle CLK_1
            cnt_100 <= 0;    // Reset counter
        end else begin
            cnt_100 <= cnt_100 + 1; // Increment counter
        end
    end

endmodule