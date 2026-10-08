module width_8to16 (
    input wire clk,
    input wire rst_n,
    input wire valid_in,
    input wire [7:0] data_in,
    output reg valid_out,
    output reg [15:0] data_out
);

    // Internal registers
    reg [7:0] data_lock;
    reg flag;

    // Initialization
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            valid_out <= 0;
            data_out <= 16'b0;
            data_lock <= 8'b0;
            flag <= 0;
        end else begin
            if (valid_in) begin
                if (flag) begin
                    // Concatenate data_lock and data_in to produce data_out
                    data_out <= {data_lock, data_in};
                    valid_out <= 1;
                    flag <= 0; // Reset the flag for the next pair of data
                end else begin
                    // Store the first valid data
                    data_lock <= data_in;
                    valid_out <= 0;
                    flag <= 1; // Set the flag to indicate the first data is stored
                end
            end else begin
                valid_out <= 0;
            end
        end
    end

endmodule