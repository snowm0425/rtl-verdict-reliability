module parallel2serial (
    input clk,         // Clock signal
    input rst_n,       // Reset signal (active low)
    input [3:0] d,     // 4-bit parallel data input
    
    output reg valid_out, // Valid signal indicating availability of serial output
    output reg dout     // Serial output
);

reg [3:0] data; // Register to hold the current data being converted
reg [1:0] cnt;  // Counter to keep track of the bit position

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        // Reset state
        valid_out <= 0;
        cnt <= 0;
        data <= 0;
        dout <= 0;
    end else begin
        if (cnt == 3) begin
            // Last bit of the parallel input
            valid_out <= 1;
            cnt <= 0;
            data <= d;
            dout <= data[3]; // Output the most significant bit
        end else begin
            // Shift the data register and output the next bit
            valid_out <= 0;
            cnt <= cnt + 1;
            data <= {data[2:0], d[3]}; // Shift left and insert the MSB of 'd'
            dout <= data[3]; // Output the current MSB of 'data'
        end
    end
end

endmodule