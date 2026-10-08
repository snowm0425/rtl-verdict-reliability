module accu (
    input        clk,
    input        rst_n,
    input  [7:0] data_in,
    input        valid_in,
    output reg   valid_out,
    output reg [9:0] data_out
);

    reg [9:0] accumulator;
    reg [2:0] counter;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            accumulator <= 10'd0;
            counter     <= 3'd0;
            valid_out   <= 1'b0;
            data_out    <= 10'd0;
        end else begin
            // Default: no valid output
            valid_out <= 1'b0;

            if (valid_in) begin
                if (counter == 3'd3) begin
                    // Fourth data: add it and output
                    accumulator <= accumulator + {2'b00, data_in};
                    data_out    <= accumulator + {2'b00, data_in};
                    valid_out   <= 1'b1;
                    counter     <= 3'd0;
                end else begin
                    // First, second, or third data: accumulate
                    accumulator <= accumulator + {2'b00, data_in};
                    counter     <= counter + 3'd1;
                end
            end
        end
    end

endmodule