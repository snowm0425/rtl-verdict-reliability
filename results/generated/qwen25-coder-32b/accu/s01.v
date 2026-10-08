module accu (
    input wire clk,
    input wire rst_n,
    input wire [7:0] data_in,
    input wire valid_in,
    output reg valid_out,
    output reg [9:0] data_out
);

    // Internal signals
    reg [1:0] count;          // Counter to track the number of valid inputs received
    reg [9:0] accumulator;    // Accumulator to sum the input data

    // Initialize the outputs
    always @(*) begin
        valid_out = 0;
        data_out = 10'b0;
    end

    // State machine to handle data accumulation
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            count <= 2'b00;
            accumulator <= 10'b0;
        end else begin
            if (valid_in) begin
                accumulator <= accumulator + data_in;
                count <= count + 1;

                if (count == 2'b11) begin  // Check if we have accumulated 4 inputs
                    data_out <= accumulator;
                    valid_out <= 1;
                    count <= 2'b00;         // Reset the count for the next batch
                    accumulator <= 10'b0;   // Reset the accumulator for the next batch
                end
            end
        end
    end

endmodule