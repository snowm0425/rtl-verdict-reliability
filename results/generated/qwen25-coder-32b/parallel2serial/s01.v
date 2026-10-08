module parallel2serial (
    input clk,         // Clock signal
    input rst_n,       // Active-low reset signal
    input [3:0] d,     // 4-bit parallel data input
    output reg valid_out, // Valid signal indicating availability of serial output
    output reg dout     // Serial output
);

    reg [3:0] data;    // Data register to hold the 4-bit data
    reg [1:0] cnt;     // Counter to track the bit position

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            // Reset state
            data <= 4'b0000;
            cnt <= 2'b00;
            valid_out <= 0;
            dout <= 0;
        end else begin
            if (cnt == 2'b11) begin
                // Last bit of the 4-bit parallel input
                data <= d;          // Update the data register with new parallel input
                cnt <= 2'b00;       // Reset counter
                valid_out <= 1;     // Set valid signal high
                dout <= data[3];    // Output the most significant bit
            end else begin
                // Intermediate bits of the 4-bit parallel input
                cnt <= cnt + 1;     // Increment the counter
                valid_out <= 0;     // Set valid signal low
                data <= {data[2:0], d[3]}; // Shift the data register left and insert the new MSB
                dout <= data[3];    // Output the most significant bit
            end
        end
    end

endmodule