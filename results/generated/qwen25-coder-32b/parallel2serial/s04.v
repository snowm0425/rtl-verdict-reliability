module parallel2serial (
    input clk,          // Clock signal
    input rst_n,        // Reset signal (active low)
    input [3:0] d,      // 4-bit parallel data input

    output reg valid_out, // Valid signal indicating the availability of serial output
    output reg dout       // Serial output representing the converted data
);

    reg [3:0] data;     // Data register to hold the parallel input
    reg [1:0] cnt;      // Counter to track the number of bits shifted

    // Sequential block to handle the logic
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            // Reset state: clear the data register, counter, and valid signal
            data <= 4'b0000;
            cnt <= 2'b00;
            valid_out <= 0;
        end else begin
            if (cnt == 2'b11) begin
                // Last bit of the parallel input is being shifted
                data <= d;        // Load new parallel data
                cnt <= 2'b00;     // Reset the counter
                valid_out <= 1;   // Set valid signal high
            end else begin
                // Shift the data register
                data <= {data[2:0], 1'b0}; // Shift left by 1 bit
                cnt <= cnt + 1;             // Increment the counter
                valid_out <= 0;             // Clear valid signal
            end
        end
    end

    // Output the most significant bit of the data register as the serial output
    assign dout = data[3];

endmodule