module serial2parallel (
    input wire clk,          // Clock signal.
    input wire rst_n,        // Reset signal (active low).
    input wire din_serial,   // Serial input data.
    input wire din_valid,    // Validity signal for input data.
    
    output reg [7:0] dout_parallel,  // Parallel output data (8 bits wide).
    output reg dout_valid            // Validity signal for the output data.
);

    reg [2:0] cnt;  // 3-bit counter to count up to 8.

    // Synchronous reset and clock operation
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            dout_parallel <= 8'b0;  // Clear the parallel output on reset.
            dout_valid <= 0;        // Clear the valid output on reset.
            cnt <= 3'b0;            // Reset the counter on reset.
        end else begin
            if (din_valid) begin
                // Shift the current value of dout_parallel left by 1 and add the new serial bit.
                dout_parallel <= {din_serial, dout_parallel[7:1]};
                cnt <= cnt + 1;  // Increment the counter.

                // Check if 8 bits have been received.
                if (cnt == 3'd7) begin
                    dout_valid <= 1;  // Set the valid output to 1.
                    cnt <= 3'b0;      // Reset the counter.
                end else begin
                    dout_valid <= 0;  // Keep the valid output to 0.
                end
            end else begin
                dout_valid <= 0;  // Keep the valid output to 0 if din_valid is 0.
            end
        end
    end

endmodule