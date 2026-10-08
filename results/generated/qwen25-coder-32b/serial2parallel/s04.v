module serial2parallel (
    input wire clk,          // Clock signal
    input wire rst_n,        // Reset signal (active low)
    input wire din_serial,   // Serial input data
    input wire din_valid,    // Validity signal for input data

    output reg [7:0] dout_parallel, // Parallel output data (8 bits wide)
    output reg dout_valid      // Validity signal for the output data
);

    reg [2:0] cnt;           // 3-bit counter to count up to 8

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            cnt <= 3'b000;      // Reset counter to 0
            dout_parallel <= 8'b0; // Reset output data to 0
            dout_valid <= 0;    // Reset output validity signal to 0
        end else if (din_valid) begin
            // Shift the current data in dout_parallel and add the new serial data
            dout_parallel <= {din_serial, dout_parallel[7:1]};
            cnt <= cnt + 1;     // Increment the counter

            // Check if 8 bits have been received
            if (cnt == 3'b111) begin
                dout_valid <= 1; // Set output validity signal to 1
                cnt <= 3'b000;   // Reset counter to 0
            end else begin
                dout_valid <= 0; // Keep output validity signal to 0
            end
        end
    end

endmodule