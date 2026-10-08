module width_8to16 (
    input wire clk,       // Clock signal
    input wire rst_n,     // Active-low reset signal
    input wire valid_in,  // Validity of the input data
    input wire [7:0] data_in,  // 8-bit input data

    output reg valid_out, // Validity of the output data
    output reg [15:0] data_out  // 16-bit output data
);

    reg [7:0] data_lock; // Register to store the first 8-bit data
    reg flag;            // Flag to indicate if the first data is stored

    // Synchronous logic on rising edge of clock or falling edge of reset
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            // Reset condition
            data_lock <= 8'b0;
            flag <= 0;
            valid_out <= 0;
            data_out <= 16'b0;
        end else begin
            if (valid_in) begin
                if (!flag) begin
                    // First valid data received
                    data_lock <= data_in;
                    flag <= 1;
                    valid_out <= 0;
                end else begin
                    // Second valid data received, concatenate with stored data
                    data_out <= {data_lock, data_in};
                    valid_out <= 1;
                    flag <= 0;
                end
            end else begin
                // If no valid data, keep valid_out low
                valid_out <= 0;
            end
        end
    end

endmodule