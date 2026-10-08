module accu (
    input wire clk,          // Clock input for synchronization
    input wire rst_n,        // Active-low reset signal
    input wire [7:0] data_in, // 8-bit input data for addition
    input wire valid_in,     // Input signal indicating readiness for new data
    output reg valid_out,    // Output signal indicating when 4 input data accumulation is reached
    output reg [9:0] data_out // 10-bit output data representing the accumulated sum
);

    // Internal registers for accumulation
    reg [9:0] acc_reg;       // Accumulator register
    reg [1:0] count_reg;     // Counter for the number of valid inputs received

    // Synchronous always block to handle the accumulation and counting
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            // Reset the accumulator and counter
            acc_reg <= 10'b0;
            count_reg <= 2'b0;
            valid_out <= 1'b0;
        end else begin
            if (valid_in) begin
                // Accumulate the incoming data
                acc_reg <= acc_reg + data_in;
                count_reg <= count_reg + 1'b1;

                // Check if we have accumulated 4 data points
                if (count_reg == 2'b11) begin
                    // Output the accumulated data
                    data_out <= acc_reg;
                    valid_out <= 1'b1;

                    // Reset the accumulator and counter for the next set of data
                    acc_reg <= 10'b0;
                    count_reg <= 2'b0;
                end else begin
                    valid_out <= 1'b0;
                end
            end else begin
                valid_out <= 1'b0;
            end
        end
    end

endmodule