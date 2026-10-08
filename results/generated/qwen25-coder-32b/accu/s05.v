module accu (
    input wire clk,
    input wire rst_n,
    input wire [7:0] data_in,
    input wire valid_in,
    output reg valid_out,
    output reg [9:0] data_out
);

    // Internal registers to store the accumulated sum and the count of valid inputs
    reg [9:0] accumulator;
    reg [1:0] count;

    // Initialize outputs and internal registers
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            accumulator <= 10'b0;
            count <= 2'b0;
            valid_out <= 1'b0;
            data_out <= 10'b0;
        end else begin
            if (valid_in) begin
                // Add the new data to the accumulator
                accumulator <= accumulator + data_in;
                count <= count + 1'b1;

                // Check if we have accumulated 4 valid inputs
                if (count == 2'b11) begin
                    // Output the accumulated result
                    data_out <= accumulator;
                    valid_out <= 1'b1;

                    // Reset the accumulator and count for the next set of inputs
                    accumulator <= 10'b0;
                    count <= 2'b0;
                end else begin
                    valid_out <= 1'b0;
                end
            end else begin
                valid_out <= 1'b0;
            end
        end
    end

endmodule