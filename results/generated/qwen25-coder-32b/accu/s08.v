module accu (
    input clk,          // Clock input for synchronization
    input rst_n,        // Active-low reset signal
    input [7:0] data_in, // 8-bit input data for addition
    input valid_in,     // Input signal indicating readiness for new data
    output reg valid_out, // Output signal indicating when 4 input data accumulation is reached
    output reg [9:0] data_out // 10-bit output data representing the accumulated sum
);

    // Internal registers
    reg [7:0] data_reg [3:0]; // Array to store 4 input data values
    reg [2:0] count;          // Counter to keep track of the number of valid data inputs

    // Initialize the output and counter
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            valid_out <= 0;
            data_out <= 0;
            count <= 0;
        end else begin
            // Check if valid_in is high and we have not accumulated 4 data points yet
            if (valid_in && (count < 4)) begin
                // Store the input data
                data_reg[count] <= data_in;
                // Increment the counter
                count <= count + 1;
            end

            // Check if we have accumulated 4 data points
            if (count == 4) begin
                // Accumulate the 4 data points
                data_out <= data_reg[0] + data_reg[1] + data_reg[2] + data_reg[3];
                // Set valid_out to 1 to indicate valid output
                valid_out <= 1;
                // Reset the counter
                count <= 0;
            end else begin
                // If not 4 data points, set valid_out to 0
                valid_out <= 0;
            end
        end
    end

endmodule