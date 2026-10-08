module serial2parallel (
    input wire clk,          // Clock signal
    input wire rst_n,        // Reset signal (active low)
    input wire din_serial,   // Serial input data
    input wire din_valid,    // Validity signal for input data
    output reg [7:0] dout_parallel, // Parallel output data (8 bits wide)
    output reg dout_valid    // Validity signal for the output data
);

    reg [2:0] cnt; // 3-bit counter to count up to 8

    // Synchronous always block
    always @(posedge clk or negedge rst_n) begin
        if (~rst_n) begin
            // Reset the counter and parallel output
            cnt <= 3'b000;
            dout_parallel <= 8'b0;
            dout_valid <= 0;
        end else if (din_valid) begin
            // Shift the serial input into the parallel output
            dout_parallel <= {dout_parallel[6:0], din_serial};
            // Increment the counter
            cnt <= cnt + 1;
            // Check if 8 bits have been received
            if (cnt == 3'b111) begin
                dout_valid <= 1; // Set the output valid signal
                cnt <= 3'b000; // Reset the counter
            end else begin
                dout_valid <= 0; // Keep the output valid signal low
            end
        end
    end

endmodule