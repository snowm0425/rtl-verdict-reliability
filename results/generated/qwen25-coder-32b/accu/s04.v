module accu (
    input clk,          // Clock input for synchronization.
    input rst_n,        // Active-low reset signal.
    input [7:0] data_in, // 8-bit input data for addition.
    input valid_in,     // Input signal indicating readiness for new data.
    output reg valid_out, // Output signal indicating when 4 input data accumulation is reached.
    output reg [9:0] data_out // 10-bit output data representing the accumulated sum.
);

    reg [1:0] count; // Counter to keep track of the number of valid data inputs.
    reg [9:0] sum;   // Accumulator to store the sum of the input data.

    // Reset the counter and sum on active-low reset.
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            count <= 2'b00;
            sum <= 10'b0;
            valid_out <= 1'b0;
        end else begin
            if (valid_in) begin
                sum <= sum + data_in; // Accumulate the data_in value.
                count <= count + 1;   // Increment the counter.

                // When 4 valid inputs are received, output the sum and set valid_out.
                if (count == 2'b11) begin
                    data_out <= sum;
                    valid_out <= 1'b1;
                    sum <= 10'b0; // Reset the sum.
                    count <= 2'b00; // Reset the counter.
                end else begin
                    valid_out <= 1'b0;
                end
            end
        end
    end

endmodule