module freq_div (
    input wire CLK_in,
    input wire RST,
    output reg CLK_50,
    output reg CLK_10,
    output reg CLK_1
);

    // Counters for CLK_10 and CLK_1 generation
    reg [3:0] cnt_10;  // Counter for 10MHz generation (counts up to 4)
    reg [5:0] cnt_100; // Counter for 1MHz generation (counts up to 49)

    // CLK_50 generation
    always @(posedge CLK_in or posedge RST) begin
        if (RST) begin
            CLK_50 <= 0;
        end else begin
            CLK_50 <= ~CLK_50; // Toggle CLK_50 on every CLK_in edge
        end
    end

    // CLK_10 generation
    always @(posedge CLK_in or posedge RST) begin
        if (RST) begin
            cnt_10 <= 4'b0;
            CLK_10 <= 0;
        end else if (cnt_10 == 4'b1001) begin // 4 + 1 = 5, but we count from 0 to 4
            CLK_10 <= ~CLK_10; // Toggle CLK_10
            cnt_10 <= 4'b0;
        end else begin
            cnt_10 <= cnt_10 + 1;
        end
    end

    // CLK_1 generation
    always @(posedge CLK_in or posedge RST) begin
        if (RST) begin
            cnt_100 <= 6'b0;
            CLK_1 <= 0;
        end else if (cnt_100 == 6'b110000) begin // 49 + 1 = 50, but we count from 0 to 49
            CLK_1 <= ~CLK_1; // Toggle CLK_1
            cnt_100 <= 6'b0;
        end else begin
            cnt_100 <= cnt_100 + 1;
        end
    end

endmodule