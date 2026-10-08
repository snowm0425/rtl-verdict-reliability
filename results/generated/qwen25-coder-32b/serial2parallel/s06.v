module serial2parallel (
    input wire clk,          // Clock signal
    input wire rst_n,        // Reset signal (active low)
    input wire din_serial,   // Serial input data
    input wire din_valid,    // Validity signal for input data
    output reg [7:0] dout_parallel, // Parallel output data (8 bits wide)
    output reg dout_valid    // Validity signal for the output data
);

    reg [2:0] cnt; // 3-bit counter to count 8 serial bits (0 to 7)

    // Synchronous always block
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            // Reset the counter and output registers
            cnt <= 3'b000;
            dout_parallel <= 8'b00000000;
            dout_valid <= 1'b0;
        end else begin
            if (din_valid) begin
                // Shift the serial input into the parallel output register
                dout_parallel[7:1] <= dout_parallel[6:0];
                dout_parallel[0] <= din_serial;
                
                // Increment the counter
                cnt <= cnt + 1;
                
                // Check if we have received 8 valid serial bits
                if (cnt == 3'b111) begin
                    // Set the valid output signal
                    dout_valid <= 1'b1;
                    // Reset the counter for the next set of bits
                    cnt <= 3'b000;
                end else begin
                    // Reset the valid output signal
                    dout_valid <= 1'b0;
                end
            end
        end
    end

endmodule