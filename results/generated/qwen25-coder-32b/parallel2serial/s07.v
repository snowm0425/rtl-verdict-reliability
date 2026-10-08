module parallel2serial (
    input wire clk,          // Clock signal
    input wire rst_n,        // Active low reset signal
    input wire [3:0] d,      // 4-bit parallel input data
    output reg valid_out,    // Valid signal indicating availability of serial output
    output reg dout          // Serial output
);

    reg [3:0] data;          // Data register to hold the parallel input
    reg [1:0] cnt;           // Counter to track the bit position

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            // Reset state
            data <= 4'b0000;  // Clear data register
            cnt <= 2'b00;     // Reset counter
            valid_out <= 0;   // Clear valid signal
        end else begin
            // Normal operation
            if (cnt == 2'b11) begin  // If counter is 3 (0b11 in 2-bit representation)
                data <= d;           // Load new parallel data
                cnt <= 2'b00;        // Reset counter
                valid_out <= 1;      // Set valid signal
            end else begin
                cnt <= cnt + 1;      // Increment counter
                valid_out <= 0;      // Clear valid signal
            end
            dout <= data[3];         // Output the most significant bit of data
            data <= {data[2:0], 1'b0}; // Shift data left by 1 bit
        end
    end

endmodule