module parallel2serial (
    input clk,          // Clock signal
    input rst_n,        // Active-low reset signal
    input [3:0] d,      // 4-bit parallel data input
    output reg valid_out, // Valid signal indicating the availability of serial output
    output reg dout       // Serial output representing the converted data
);

    reg [1:0] cnt; // Counter to keep track of the bit position
    reg [3:0] data; // Register to hold the parallel data

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            // Reset state
            cnt <= 2'b00;
            valid_out <= 0;
            dout <= 0;
            data <= 4'b0000;
        end else begin
            if (cnt == 2'b11) begin
                // Last bit of the parallel input is being output
                valid_out <= 1;
                cnt <= 2'b00; // Reset counter
                data <= d; // Load new data
                dout <= data[3]; // Output MSB
            end else begin
                // Output the next bit in the next clock cycle
                valid_out <= 0;
                cnt <= cnt + 1; // Increment counter
                dout <= data[3]; // Output current MSB
                data <= {data[2:0], 1'b0}; // Shift data to the left
            end
        end
    end

endmodule