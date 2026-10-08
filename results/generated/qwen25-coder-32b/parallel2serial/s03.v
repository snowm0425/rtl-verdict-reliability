module parallel2serial (
    input clk,          // Clock signal
    input rst_n,        // Active low reset signal
    input [3:0] d,      // 4-bit parallel input
    output reg valid_out, // Valid signal for serial output
    output reg dout     // Serial output
);

    reg [3:0] data;   // Data register to hold the parallel input
    reg [1:0] cnt;    // Counter to track the number of bits processed

    // Sequential logic to update the data register and counter
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            // Reset condition
            data <= 4'b0000;
            cnt <= 2'b00;
            valid_out <= 0;
            dout <= 0;
        end else begin
            // Normal operation
            if (cnt == 2'b11) begin
                // Last bit is being processed
                data <= d;
                cnt <= 2'b00;
                valid_out <= 1;
                dout <= data[3];
            end else begin
                // Processing the first three bits
                cnt <= cnt + 1;
                valid_out <= 0;
                data <= {data[2:0], d[3]};
                dout <= data[3];
            end
        end
    end

endmodule