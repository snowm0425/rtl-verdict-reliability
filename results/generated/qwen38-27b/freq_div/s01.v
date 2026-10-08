module freq_div (
    input  CLK_in,
    input  RST,
    output CLK_50,
    output CLK_10,
    output CLK_1
);

    // Registers for clock outputs
    reg CLK_50_reg;
    reg CLK_10_reg;
    reg CLK_1_reg;

    // Counters
    reg [2:0] cnt_10;   // 3-bit counter to count up to 4
    reg [6:0] cnt_100;  // 7-bit counter to count up to 49

    // Assign output clocks from registers
    assign CLK_50 = CLK_50_reg;
    assign CLK_10 = CLK_10_reg;
    assign CLK_1  = CLK_1_reg;

    // CLK_50: Divide by 2
    always @(posedge CLK_in or posedge RST) begin
        if (RST)
            CLK_50_reg <= 1'b0;
        else
            CLK_50_reg <= ~CLK_50_reg;
    end

    // CLK_10: Divide by 10
    always @(posedge CLK_in or posedge RST) begin
        if (RST) begin
            CLK_10_reg <= 1'b0;
            cnt_10     <= 3'd0;
        end else begin
            if (cnt_10 == 3'd4) begin
                CLK_10_reg <= ~CLK_10_reg;
                cnt_10     <= 3'd0;
            end else begin
                cnt_10 <= cnt_10 + 3'd1;
            end
        end
    end

    // CLK_1: Divide by 100
    always @(posedge CLK_in or posedge RST) begin
        if (RST) begin
            CLK_1_reg  <= 1'b0;
            cnt_100    <= 7'd0;
        end else begin
            if (cnt_100 == 7'd49) begin
                CLK_1_reg <= ~CLK_1_reg;
                cnt_100   <= 7'd0;
            end else begin
                cnt_100 <= cnt_100 + 7'd1;
            end
        end
    end

endmodule