module width_8to16 (
    input wire clk,          // Clock signal
    input wire rst_n,        // Active-low reset signal
    input wire valid_in,     // Validity of input data
    input wire [7:0] data_in, // 8-bit input data
    
    output reg valid_out,    // Validity of output data
    output reg [15:0] data_out // 16-bit output data
);

    // Internal registers
    reg [7:0] data_lock;     // Register to store the first 8-bit data
    reg flag;                // Flag to indicate if the first data is stored

    // Synchronous process on positive edge of clock and negative edge of reset
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            // Reset condition
            valid_out <= 0;
            data_out <= 16'b0;
            data_lock <= 8'b0;
            flag <= 0;
        end else begin
            if (valid_in) begin
                if (!flag) begin
                    // First valid data received, store it
                    data_lock <= data_in;
                    flag <= 1;
                end else begin
                    // Second valid data received, concatenate and output
                    data_out <= {data_lock, data_in};
                    valid_out <= 1;
                    // Reset flag for the next pair of data
                    flag <= 0;
                end
            end else begin
                // If no valid data, just clear valid_out
                valid_out <= 0;
            end
        end
    end

endmodule