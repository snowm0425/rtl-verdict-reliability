module freq_div (
    input  wire CLK_in,
    input  wire RST,
    output reg  CLK_50,
    output reg  CLK_10,
    output reg  CLK_1
);

    // Counter for 10MHz division (divide by 10)
    // Needs to count from 0 to 4 (5 states) to toggle every 5 cycles
    // Total period = 10 input cycles -> 10MHz from 100MHz
    reg [2:0] cnt_10;

    // Counter for 1MHz division (divide by 100)
    // Needs to count from 0 to 49 (50 states) to toggle every 50 cycles
    // Total period = 100 input cycles -> 1MHz from 100MHz
    reg [5:0] cnt_100;

    // CLK_50: Divide by 2
    // Simply toggle on every clock edge
    always @(posedge CLK_in or posedge RST) begin
        if (RST) begin
            CLK_50 <= 1'b0;
        end else begin
            CLK_50 <= ~CLK_50;
        end
    end

    // CLK_10: Divide by 10
    // Toggle every 5 input clock cycles (counter counts 0,1,2,3,4)
    always @(posedge CLK_in or posedge RST) begin
        if (RST) begin
            CLK_10 <= 1'b0;
            cnt_10 <= 3'd0;
        end else begin
            if (cnt_10 == 3'd4) begin
                CLK_10 <= ~CLK_10;
                cnt_10 <= 3'd0;
            end else begin
                cnt_10 <= cnt_10 + 1'b1;
            end
        end
    end

    // CLK_1: Divide by 100
    // Toggle every 50 input clock cycles (counter counts 0 to 49)
    always @(posedge CLK_in or posedge RST) begin
        if (RST) begin
            CLK_1 <= 1'b0;
            cnt_100 <= 6'd0;
        end else begin
            if (cnt_100 == 6'd49) begin
                CLK_1 <= ~CLK_1;
                cnt_100 <= 6'd0;
            end else begin
                cnt_100 <= cnt_100 + 1'b1;
            end
        end
    end

endmodule