module accu (
    input wire clk,          // Clock input for synchronization
    input wire rst_n,        // Active-low reset signal
    input wire [7:0] data_in, // 8-bit input data for addition
    input wire valid_in,     // Input signal indicating readiness for new data
    output reg valid_out,    // Output signal indicating when 4 input data accumulation is reached
    output reg [9:0] data_out // 10-bit output data representing the accumulated sum
);

    // Internal registers to hold the accumulated sum and the count of valid inputs
    reg [9:0] accumulator;
    reg [1:0] count;

    // Initialize the outputs and internal registers on reset
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            valid_out <= 0;
            data_out <= 0;
            accumulator <= 0;
            count <= 0;
        end else begin
            if (valid_in) begin
                // Accumulate the input data
                accumulator <= accumulator + data_in;
                // Increment the count of valid inputs
                count <= count + 1;

                // Check if we have accumulated 4 valid inputs
                if (count == 3) begin
                    // Set the output data to the accumulated sum
                    data_out <= accumulator + data_in;
                    // Set the valid output signal
                    valid_out <= 1;
                    // Reset the accumulator and count for the next batch
                    accumulator <= 0;
                    count <= 0;
                end else begin
                    // If not yet 4, clear the valid output signal
                    valid_out <= 0;
                end
            end else begin
                // If no valid input, clear the valid output signal
                valid_out <= 0;
            end
        end
    end

endmodule