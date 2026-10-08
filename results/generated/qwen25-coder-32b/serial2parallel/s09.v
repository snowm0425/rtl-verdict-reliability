module serial2parallel (
    input clk,          // Clock signal
    input rst_n,        // Reset signal (active low)
    input din_serial,   // Serial input data
    input din_valid,    // Validity signal for input data
    output reg [7:0] dout_parallel, // Parallel output data (8 bits wide)
    output reg dout_valid // Validity signal for the output data
);

    // 3-bit counter to count the number of serial bits received
    reg [2:0] cnt;

    // Synchronous process on rising edge of clock
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            // Reset state
            cnt <= 3'b000;
            dout_parallel <= 8'b00000000;
            dout_valid <= 0;
        end else begin
            if (din_valid) begin
                // Shift the serial input into the parallel output
                dout_parallel <= {dout_parallel[6:0], din_serial};
                // Increment the counter
                cnt <= cnt + 1;
                // Check if we have received 8 valid bits
                if (cnt == 3'b111) begin
                    dout_valid <= 1;
                    // Reset the counter for the next 8 bits
                    cnt <= 3'b000;
                end else begin
                    dout_valid <= 0;
                end
            end else begin
                // If din_valid is not asserted, keep the output valid signal low
                dout_valid <= 0;
            end
        end
    end

endmodule