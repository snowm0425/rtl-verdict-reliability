module serial2parallel (
    input        clk,
    input        rst_n,
    input        din_serial,
    input        din_valid,
    output [7:0] dout_parallel,
    output       dout_valid
);

    reg [2:0] cnt;
    reg [7:0] dout_parallel_reg;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            cnt <= 3'd0;
            dout_parallel_reg <= 8'd0;
        end else begin
            if (din_valid) begin
                // Shift the received bit into the appropriate position
                // First bit received goes to MSB (bit 7), next to bit 6, etc.
                dout_parallel_reg[7 - cnt] <= din_serial;
                
                if (cnt == 3'd7) begin
                    // 8th bit received, reset counter
                    cnt <= 3'd0;
                end else begin
                    cnt <= cnt + 3'd1;
                end
            end
        end
    end

    assign dout_parallel = dout_parallel_reg;
    assign dout_valid = (cnt == 3'd7) && din_valid;

endmodule