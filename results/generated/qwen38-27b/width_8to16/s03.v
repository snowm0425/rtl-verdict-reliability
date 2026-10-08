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

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            data_lock <= 8'd0;
            flag <= 1'b0;
            valid_out <= 1'b0;
            data_out <= 16'd0;
        end else begin
            if (valid_in) begin
                if (!flag) begin
                    // First valid data: store it and set flag
                    data_lock <= data_in;
                    flag <= 1'b1;
                    valid_out <= 1'b0;
                end else begin
                    // Second valid data: concatenate and output
                    data_out <= {data_lock, data_in};
                    valid_out <= 1'b1;
                    flag <= 1'b0;
                end
            end else begin
                // No valid input: clear valid_out
                valid_out <= 1'b0;
            end
        end
    end

endmodule