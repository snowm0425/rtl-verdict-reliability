module accu (
    input wire clk,           // Clock input for synchronization.
    input wire rst_n,         // Active-low reset signal.
    input wire [7:0] data_in, // 8-bit input data for addition.
    input wire valid_in,      // Input signal indicating readiness for new data.
    output reg valid_out,     // Output signal indicating when 4 input data accumulation is reached.
    output reg [9:0] data_out // 10-bit output data representing the accumulated sum.
);

    // Internal registers for accumulation and counting
    reg [9:0] acc;           // Accumulator to hold the sum of 4 data_in values.
    reg [1:0] count;         // Counter to track the number of valid data_in inputs.

    // Initialize the output signals
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            acc <= 10'b0;       // Reset the accumulator.
            count <= 2'b00;     // Reset the counter.
            valid_out <= 1'b0;  // Reset the valid_out signal.
            data_out <= 10'b0;  // Reset the data_out signal.
        end else begin
            if (valid_in) begin
                // Add the current data_in to the accumulator.
                acc <= acc + data_in;
                // Increment the counter.
                count <= count + 1;
                // Check if we have accumulated 4 data_in values.
                if (count == 2'b11) begin
                    // Set the valid_out signal to indicate valid data_out.
                    valid_out <= 1'b1;
                    // Assign the accumulated value to data_out.
                    data_out <= acc;
                    // Reset the accumulator and counter for the next set of inputs.
                    acc <= 10'b0;
                    count <= 2'b00;
                end else begin
                    // If not yet 4 inputs, clear the valid_out signal.
                    valid_out <= 1'b0;
                end
            end else begin
                // If no new valid data, keep valid_out low.
                valid_out <= 1'b0;
            end
        end
    end

endmodule