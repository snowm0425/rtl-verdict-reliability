module width_8to16 (
    input wire clk,        // Clock signal
    input wire rst_n,      // Active-low reset signal
    input wire valid_in,   // Validity of input data
    input wire [7:0] data_in, // 8-bit input data
    
    output reg valid_out,  // Validity of output data
    output reg [15:0] data_out // 16-bit output data
);

    reg [7:0] data_lock;  // Register to store the first 8-bit data
    reg data_valid_flag;  // Flag to indicate if the first data is stored

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            // Reset all registers
            data_lock <= 8'b0;
            data_valid_flag <= 0;
            valid_out <= 0;
            data_out <= 16'b0;
        end else begin
            if (valid_in) begin
                if (!data_valid_flag) begin
                    // Store the first 8-bit data and set the flag
                    data_lock <= data_in;
                    data_valid_flag <= 1;
                    valid_out <= 0;
                end else begin
                    // Concatenate the stored data with the new data
                    data_out <= {data_lock, data_in};
                    valid_out <= 1;
                    // Clear the flag for the next cycle
                    data_valid_flag <= 0;
                end
            end else begin
                // No new data, keep valid_out low
                valid_out <= 0;
            end
        end
    end

endmodule