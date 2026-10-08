module parallel2serial (
    input wire clk,          // Clock signal
    input wire rst_n,        // Active-low reset signal
    input wire [3:0] d,      // 4-bit parallel data input
    
    output reg valid_out,    // Valid signal indicating availability of serial output
    output reg dout          // Serial output
);

    reg [3:0] data;          // Data register to hold the parallel data
    reg [1:0] cnt;           // Counter to keep track of the bit position

    // Sequential logic to handle the conversion
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            // Reset state
            data <= 4'b0000;
            cnt <= 2'b00;
            valid_out <= 0;
            dout <= 0;
        end else begin
            // Normal operation
            if (cnt == 2'b11) begin  // When the counter reaches 3 (binary 11)
                data <= d;          // Load new parallel data
                cnt <= 2'b00;       // Reset counter
                valid_out <= 1;     // Set valid output to 1
                dout <= d[3];       // Output the most significant bit
            end else begin
                // Shift the data register and output the next bit
                cnt <= cnt + 1;     // Increment counter
                valid_out <= 0;     // Set valid output to 0
                dout <= data[3];    // Output the current most significant bit
                data <= {data[2:0], 1'b0}; // Shift data register to the left
            end
        end
    end

endmodule