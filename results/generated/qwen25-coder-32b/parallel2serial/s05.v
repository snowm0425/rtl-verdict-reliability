module parallel2serial (
    input clk,          // Clock signal
    input rst_n,        // Active-low reset signal
    input [3:0] d,      // 4-bit parallel input data
    output reg valid_out, // Valid signal indicating the availability of serial output
    output reg dout       // Serial output
);

    reg [3:0] data; // Data register to hold the parallel input
    reg [1:0] cnt;  // Counter to keep track of the bit position

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            // Reset the counter and valid signal
            cnt <= 2'b00;
            valid_out <= 0;
            data <= 4'b0000;
            dout <= 0;
        end else begin
            // Shift the data register to the left and assign the most significant bit to dout
            dout <= data[3];
            data <= {d[0], data[3:1]};
            
            if (cnt == 2'b11) begin // If counter reaches 3 (binary 11)
                // Load the new parallel input data into the data register
                data <= d;
                // Reset the counter
                cnt <= 2'b00;
                // Set the valid signal to indicate the availability of valid serial output
                valid_out <= 1;
            end else begin
                // Increment the counter
                cnt <= cnt + 1;
                // Clear the valid signal
                valid_out <= 0;
            end
        end
    end

endmodule