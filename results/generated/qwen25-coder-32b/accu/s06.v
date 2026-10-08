module accu (
    input wire clk,
    input wire rst_n,
    input wire [7:0] data_in,
    input wire valid_in,
    output reg [9:0] data_out,
    output reg valid_out
);

    // Internal registers to hold the accumulated sum and the count of received data
    reg [9:0] acc_sum;
    reg [1:0] data_count;

    // Initialize the accumulated sum and count on reset
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            acc_sum <= 10'b0;
            data_count <= 2'b0;
            valid_out <= 1'b0;
        end else begin
            // Check if valid_in is high and accumulate the data
            if (valid_in) begin
                acc_sum <= acc_sum + data_in;
                data_count <= data_count + 1;
            end

            // Check if we have accumulated 4 data points
            if (data_count == 2'b11) begin
                data_out <= acc_sum;
                valid_out <= 1'b1;
                // Reset the accumulated sum and count
                acc_sum <= 10'b0;
                data_count <= 2'b0;
            end else begin
                valid_out <= 1'b0;
            end
        end
    end

endmodule