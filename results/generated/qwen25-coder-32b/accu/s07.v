module accu (
    input wire clk,
    input wire rst_n,
    input wire [7:0] data_in,
    input wire valid_in,
    output reg valid_out,
    output reg [9:0] data_out
);

    // Internal registers
    reg [1:0] count; // Counter to keep track of number of valid inputs
    reg [9:0] accumulator; // Accumulator to sum the data

    // Initialize outputs
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            valid_out <= 0;
            data_out <= 0;
            count <= 0;
            accumulator <= 0;
        end else begin
            if (valid_in) begin
                // Accumulate the input data
                accumulator <= accumulator + data_in;
                // Increment the count of valid inputs
                count <= count + 1;
            end

            // Check if 4 valid inputs have been received
            if (count == 3) begin // Count starts from 0, so 3 means 4 inputs
                // Set the output data and valid signal
                data_out <= accumulator;
                valid_out <= 1;

                // Reset the count and accumulator for the next set of inputs
                count <= 0;
                accumulator <= 0;
            end else begin
                // Otherwise, clear the valid signal
                valid_out <= 0;
            end
        end
    end

endmodule