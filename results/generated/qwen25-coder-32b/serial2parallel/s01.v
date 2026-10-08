module serial2parallel (
    input wire clk,
    input wire rst_n,
    input wire din_serial,
    input wire din_valid,
    output reg [7:0] dout_parallel,
    output reg dout_valid
);

    // 4-bit counter to track the number of serial input bits received
    reg [3:0] cnt;

    // Initialize the output and the counter
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            dout_parallel <= 8'b0;
            dout_valid  <= 0;
            cnt         <= 4'b0;
        end else begin
            if (din_valid) begin
                // Shift the serial input into the parallel output register
                dout_parallel <= {dout_parallel[6:0], din_serial};
                // Increment the counter
                cnt <= cnt + 1;
                // Check if 8 bits have been received
                if (cnt == 4'b111) begin
                    // Set the valid output signal
                    dout_valid <= 1;
                    // Reset the counter
                    cnt <= 4'b0;
                end else begin
                    // Reset the valid output signal
                    dout_valid <= 0;
                end
            end
        end
    end

endmodule