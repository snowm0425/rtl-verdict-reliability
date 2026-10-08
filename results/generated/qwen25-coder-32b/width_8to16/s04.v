module width_8to16 (
    input wire clk,          // Clock signal
    input wire rst_n,        // Active-low reset signal
    input wire valid_in,     // Input data validity signal
    input wire [7:0] data_in, // 8-bit input data
    output reg valid_out,    // Output data validity signal
    output reg [15:0] data_out // 16-bit output data
);

    // Internal register to store the first 8-bit input data
    reg [7:0] data_lock;

    // Flag to indicate if we have already stored the first 8-bit data
    reg first_data_stored;

    // Synchronous process to handle the data conversion and output generation
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            // Reset state
            valid_out <= 0;
            data_out <= 16'b0;
            data_lock <= 8'b0;
            first_data_stored <= 0;
        end else if (valid_in) begin
            if (!first_data_stored) begin
                // Store the first 8-bit data
                data_lock <= data_in;
                first_data_stored <= 1;
            end else begin
                // Concatenate the first 8-bit data with the second 8-bit data
                data_out <= {data_lock, data_in};
                valid_out <= 1;
                first_data_stored <= 0;
            end
        end else begin
            // No new valid data, keep the output valid signal low
            valid_out <= 0;
        end
    end

endmodule