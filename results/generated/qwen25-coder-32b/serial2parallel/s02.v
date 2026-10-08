module serial2parallel (
    input clk,          // Clock signal
    input rst_n,        // Reset signal (active low)
    input din_serial,   // Serial input data
    input din_valid,    // Validity signal for input data
    output reg [7:0] dout_parallel, // Parallel output data (8 bits wide)
    output reg dout_valid // Validity signal for the output data
);

    reg [2:0] cnt; // 3-bit counter to count 0 to 7

    // Synchronous process to handle the serial to parallel conversion
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            // Reset state
            cnt <= 3'b000;
            dout_parallel <= 8'b0;
            dout_valid <= 1'b0;
        end else if (din_valid) begin
            // Shift the serial input into the parallel register
            dout_parallel[7:1] <= dout_parallel[6:0]; // Shift left by 1
            dout_parallel[0] <= din_serial;           // Insert the new serial bit

            // Increment the counter
            cnt <= cnt + 1;

            // Check if we have received 8 bits
            if (cnt == 3'b111) begin
                dout_valid <= 1'b1; // Set valid signal
                cnt <= 3'b000;      // Reset counter
            end else begin
                dout_valid <= 1'b0; // Keep valid signal low
            end
        end else begin
            // If din_valid is low, keep dout_valid low
            dout_valid <= 1'b0;
        end
    end

endmodule