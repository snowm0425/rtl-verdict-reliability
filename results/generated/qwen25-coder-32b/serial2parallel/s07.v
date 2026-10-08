module serial2parallel (
    input wire clk,          // Clock signal
    input wire rst_n,        // Reset signal (active low)
    input wire din_serial,   // Serial input data
    input wire din_valid,    // Validity signal for input data
    output reg [7:0] dout_parallel, // Parallel output data (8 bits wide)
    output reg dout_valid    // Validity signal for the output data
);

    reg [2:0] cnt; // 3-bit counter to keep track of the number of serial bits received

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            cnt <= 3'b000; // Reset counter
            dout_parallel <= 8'b00000000; // Clear parallel output
            dout_valid <= 1'b0; // Output data is invalid
        end else if (din_valid) begin
            dout_parallel[7 - cnt] <= din_serial; // Shift serial data into parallel output

            if (cnt == 3'b111) begin // If 8 bits have been received
                cnt <= 3'b000; // Reset counter
                dout_valid <= 1'b1; // Output data is valid
            end else begin
                cnt <= cnt + 1; // Increment counter
                dout_valid <= 1'b0; // Output data is still invalid
            end
        end
    end

endmodule