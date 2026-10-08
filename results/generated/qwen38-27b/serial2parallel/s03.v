module serial2parallel (
    input  wire       clk,
    input  wire       rst_n,
    input  wire       din_serial,
    input  wire       din_valid,
    output reg  [7:0] dout_parallel,
    output reg        dout_valid
);

    reg [3:0] cnt;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            cnt           <= 4'd0;
            dout_parallel <= 8'd0;
            dout_valid    <= 1'b0;
        end else begin
            // Default: clear output valid every cycle
            dout_valid <= 1'b0;

            if (din_valid) begin
                if (cnt == 4'd7) begin
                    // Last bit (LSB) being shifted in
                    dout_parallel[0] <= din_serial;
                    dout_valid       <= 1'b1;
                    cnt              <= 4'd0; // Reset counter for next sequence
                end else begin
                    // Shift existing bits right, new bit goes to MSB
                    dout_parallel <= {din_serial, dout_parallel[7:1]};
                    cnt           <= cnt + 4'd1;
                end
            end
        end
    end

endmodule