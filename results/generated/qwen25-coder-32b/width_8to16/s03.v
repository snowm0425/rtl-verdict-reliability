module width_8to16 (
    input wire clk,        // Clock signal
    input wire rst_n,      // Active-low reset signal
    input wire valid_in,   // Validity of the input data
    input wire [7:0] data_in, // 8-bit input data
    output wire valid_out, // Validity of the output data
    output wire [15:0] data_out // 16-bit output data
);

    reg [7:0] data_lock;   // Temporary storage for the first 8-bit data
    reg valid_flag;        // Flag to indicate the arrival of the first valid data
    reg [15:0] data_out_reg; // Register to store the final 16-bit output data
    reg valid_out_reg;     // Register to store the validity of the output data

    // Sequential logic to handle the data conversion
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            // On reset, clear all registers
            data_lock <= 8'b0;
            valid_flag <= 1'b0;
            data_out_reg <= 16'b0;
            valid_out_reg <= 1'b0;
        end else begin
            if (valid_in) begin
                if (!valid_flag) begin
                    // Store the first valid data in data_lock
                    data_lock <= data_in;
                    valid_flag <= 1'b1;
                end else begin
                    // Concatenate the second valid data with data_lock to form data_out
                    data_out_reg <= {data_lock, data_in};
                    valid_out_reg <= 1'b1;
                    // Reset the flag for the next cycle
                    valid_flag <= 1'b0;
                end
            end else begin
                // If no valid data is received, reset the flag
                valid_out_reg <= 1'b0;
            end
        end
    end

    // Assign the registered outputs to the module outputs
    assign valid_out = valid_out_reg;
    assign data_out = data_out_reg;

endmodule