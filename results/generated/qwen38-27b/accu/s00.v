module accu (
    input        clk,
    input        rst_n,
    input  [7:0] data_in,
    input        valid_in,
    output reg   valid_out,
    output [9:0] data_out
);

    reg [9:0] acc_sum;
    reg [1:0] count;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            acc_sum   <= 10'd0;
            count     <= 2'd0;
            valid_out <= 1'b0;
        end else begin
            // Default: no valid output
            valid_out <= 1'b0;

            if (valid_in) begin
                if (count == 2'd3) begin
                    // Fourth data: accumulate and output
                    acc_sum   <= {2'd0, data_in} + acc_sum;
                    count     <= 2'd0;
                    valid_out <= 1'b1;
                end else begin
                    // First, second, or third data: accumulate
                    acc_sum   <= {2'd0, data_in} + acc_sum;
                    count     <= count + 2'd1;
                end
            end
        end
    end

    assign data_out = acc_sum;

endmodule