module accu (
    input wire clk,            // Clock input for synchronization
    input wire rst_n,          // Active-low reset signal
    input wire [7:0] data_in,  // 8-bit input data for addition
    input wire valid_in,       // Input signal indicating readiness for new data
    output reg valid_out,      // Output signal indicating when 4 input data accumulation is reached
    output reg [9:0] data_out  // 10-bit output data representing the accumulated sum
);

    reg [7:0] data_buffer [3:0];  // Buffer to store 4 input data values
    reg [1:0] count;              // Counter to track the number of valid inputs received

    // Initialize outputs and buffer on reset
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            valid_out <= 0;
            data_out <= 0;
            count <= 0;
            data_buffer[0] <= 0;
            data_buffer[1] <= 0;
            data_buffer[2] <= 0;
            data_buffer[3] <= 0;
        end else begin
            if (valid_in) begin
                data_buffer[count] <= data_in;  // Store the input data in the buffer
                if (count == 3) begin           // If we have 4 valid inputs
                    data_out <= data_buffer[0] + data_buffer[1] + data_buffer[2] + data_buffer[3]; // Accumulate the sum
                    valid_out <= 1;             // Set valid_out to 1 to indicate output is ready
                    count <= 0;                 // Reset the counter
                end else begin
                    count <= count + 1;         // Increment the counter
                end
            end else begin
                valid_out <= 0;                 // Clear valid_out if no new valid input
            end
        end
    end

endmodule