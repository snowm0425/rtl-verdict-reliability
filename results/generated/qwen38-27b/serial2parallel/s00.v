module serial2parallel (
    input  wire       clk,
    input  wire       rst_n,
    input  wire       din_serial,
    input  wire       din_valid,
    output reg  [7:0] dout_parallel,
    output reg        dout_valid
);

    reg [3:0] cnt;
    reg [7:0] data_reg;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            cnt <= 4'd0;
            data_reg <= 8'd0;
            dout_parallel <= 8'd0;
            dout_valid <= 1'b0;
        end else begin
            if (din_valid) begin
                // Shift in the new bit as MSB
                data_reg <= {din_serial, data_reg[7:1]};
                if (cnt == 4'd7) begin
                    // 8th bit received, output the full 8-bit word
                    dout_parallel <= data_reg;
                    dout_valid <= 1'b1;
                    cnt <= 4'd0;
                end else begin
                    dout_valid <= 1'b0;
                    cnt <= cnt + 4'd1;
                end
            end else begin
                // No valid input, clear valid signal
                dout_valid <= 1'b0;
            end
        end
    end

endmodule