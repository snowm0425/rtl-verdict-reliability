module serial2parallel (
    input wire clk,          // Clock signal
    input wire rst_n,        // Reset signal (active low)
    input wire din_serial,   // Serial input data
    input wire din_valid,    // Validity signal for input data
    
    output reg [7:0] dout_parallel, // Parallel output data (8 bits wide)
    output reg dout_valid     // Validity signal for the output data
);

    reg [2:0] cnt; // 3-bit counter to count up to 8 serial bits

    // Synchronous process on the rising edge of the clock
    always @(posedge clk or negedge rst_n) begin
        if (~rst_n) begin
            // Reset state
            cnt <= 3'b000; // Reset counter
            dout_parallel <= 8'b00000000; // Clear parallel output
            dout_valid <= 1'b0; // Output is not valid
        end else if (din_valid) begin
            // Shift serial input into the parallel output register
            dout_parallel[7:1] <= dout_parallel[6:0]; // Shift left
            dout_parallel[0] <= din_serial; // Place new serial bit at least significant bit
            
            // Increment the counter
            cnt <= cnt + 1;
            
            // Check if 8 bits have been received
            if (cnt == 3'd7) begin
                cnt <= 3'b000; // Reset counter after 8 bits
                dout_valid <= 1'b1; // Output is valid
            end else begin
                dout_valid <= 1'b0; // Output is not valid
            end
        end
    end

endmodule