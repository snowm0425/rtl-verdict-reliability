module parallel2serial (
    input clk,        // Clock signal
    input rst_n,      // Reset signal (active low)
    input [3:0] d,    // 4-bit parallel data input
    output reg valid_out, // Valid signal indicating the availability of serial output
    output reg dout     // Serial output representing the converted data
);

reg [1:0] cnt;       // Counter to track the bit position
reg [3:0] data;      // Register to store the parallel data for serial conversion

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        // Reset condition
        cnt <= 2'b00;
        data <= 4'b0000;
        valid_out <= 1'b0;
        dout <= 1'b0;
    end else begin
        // Normal operation
        if (cnt == 2'b11) begin
            // Last bit of the parallel input is being output
            data <= d;
            cnt <= 2'b00;
            valid_out <= 1'b1;
        end else begin
            // Output the current bit and shift the data register
            data <= {data[2:0], d[3]};
            cnt <= cnt + 1'b1;
            valid_out <= 1'b0;
        end
        // Assign the most significant bit of the data register to the serial output
        dout <= data[3];
    end
end

endmodule