module serial2parallel (
    input  wire        clk,
    input  wire        rst_n,
    input  wire        din_serial,
    input  wire        din_valid,
    output reg  [7:0]  dout_parallel,
    output reg         dout_valid
);

    reg [3:0] cnt;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            cnt            <= 4'd0;
            dout_parallel  <= 8'b0;
            dout_valid     <= 1'b0;
        end else begin
            if (din_valid) begin
                if (cnt == 4'd7) begin
                    // Last bit (LSB) is being received
                    dout_parallel[0] <= din_serial;
                    dout_valid       <= 1'b1;
                    cnt              <= 4'd0;
                end else begin
                    // Shift previous data right and put new bit at MSB
                    dout_parallel <= {din_serial, dout_parallel[7:1]};
                    dout_valid    <= 1'b0;
                    cnt           <= cnt + 4'd1;
                end
            end else begin
                // No valid input, clear valid signal
                dout_valid <= 1'b0;
            end
        end
    end

endmodule