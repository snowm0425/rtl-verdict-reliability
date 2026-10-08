module serial2parallel (
    input wire clk,          // Clock signal
    input wire rst_n,        // Reset signal (active low)
    input wire din_serial,   // Serial input data
    input wire din_valid,    // Validity signal for input data
    output reg [7:0] dout_parallel, // Parallel output data
    output reg dout_valid    // Validity signal for output data
);

    reg [2:0] cnt; // 3-bit counter to count 8 serial bits

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            cnt <= 3'b000;
            dout_parallel <= 8'b0;
            dout_valid <= 0;
        end else if (din_valid) begin
            // Shift the current dout_parallel value left by 1 and add the new serial data
            dout_parallel <= {dout_parallel[6:0], din_serial};
            cnt <= cnt + 1;

            // Check if we have received 8 bits
            if (cnt == 3'b111) begin
                dout_valid <= 1; // Set valid signal high
                cnt <= 3'b000; // Reset counter
            end else begin
                dout_valid <= 0; // Keep valid signal low
            end
        end
    end

endmodule