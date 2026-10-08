module width_8to16 (
    input wire clk,          // Clock signal
    input wire rst_n,        // Active-low reset signal
    input wire valid_in,     // Validity of input data
    input wire [7:0] data_in, // 8-bit input data

    output reg valid_out,    // Validity of output data
    output reg [15:0] data_out // 16-bit output data
);

    reg [7:0] data_lock;    // Temporary storage for the first 8-bit input
    reg flag;              // Flag to indicate if the first data has been captured

    // Reset and clocked logic
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            // Reset conditions
            data_out <= 16'b0;
            valid_out <= 1'b0;
            data_lock <= 8'b0;
            flag <= 1'b0;
        end else begin
            if (valid_in) begin
                if (flag) begin
                    // Second valid data received, concatenate and output
                    data_out <= {data_lock, data_in};
                    valid_out <= 1'b1;
                    // Reset flag and clear data_lock
                    flag <= 1'b0;
                    data_lock <= 8'b0;
                end else begin
                    // First valid data received, store in data_lock
                    data_lock <= data_in;
                    flag <= 1'b1;
                end
            end else begin
                // No valid input, clear output and flag
                valid_out <= 1'b0;
            end
        end
    end

endmodule