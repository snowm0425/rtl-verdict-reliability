module width_8to16 (
    input wire clk,          // Clock signal
    input wire rst_n,        // Active-low reset signal
    input wire valid_in,     // Validity of the input data
    input wire [7:0] data_in, // 8-bit input data

    output reg valid_out,    // Validity of the output data
    output reg [15:0] data_out // 16-bit output data
);

    reg [7:0] data_lock;    // Register to store the first 8-bit input
    reg first_valid_flag;   // Flag to indicate if the first valid data has been received

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            // Reset all registers and flags
            valid_out <= 0;
            data_out <= 16'b0;
            data_lock <= 8'b0;
            first_valid_flag <= 0;
        end else begin
            if (valid_in) begin
                if (!first_valid_flag) begin
                    // Store the first valid 8-bit data
                    data_lock <= data_in;
                    first_valid_flag <= 1;
                end else begin
                    // Concatenate the second valid 8-bit data with the stored data
                    data_out <= {data_lock, data_in};
                    valid_out <= 1;
                    // Reset the flag for the next pair of inputs
                    first_valid_flag <= 0;
                end
            end else begin
                // If no new valid input, keep the output valid signal low
                valid_out <= 0;
            end
        end
    end

endmodule