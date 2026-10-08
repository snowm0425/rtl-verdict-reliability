module accu (
    input        clk,
    input        rst_n,
    input  [7:0] data_in,
    input        valid_in,
    output reg   valid_out,
    output [9:0] data_out
);

    // Internal signals
    reg [7:0] data_reg [0:3];  // Register to store 4 input data values
    reg [2:0] count;           // Counter to track how many valid inputs received (0-3)
    reg [9:0] sum;             // Accumulated sum

    // Output data is the accumulated sum
    assign data_out = sum;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            count <= 3'd0;
            valid_out <= 1'b0;
            sum <= 10'd0;
            data_reg[0] <= 8'd0;
            data_reg[1] <= 8'd0;
            data_reg[2] <= 8'd0;
            data_reg[3] <= 8'd0;
        end else begin
            // Default: valid_out is 0
            valid_out <= 1'b0;

            if (valid_in) begin
                if (count == 3'd3) begin
                    // We have 4 valid inputs, compute sum and output
                    sum <= {2'b0, data_reg[0]} + {2'b0, data_reg[1]} + {2'b0, data_reg[2]} + {2'b0, data_reg[3]};
                    valid_out <= 1'b1;
                    // Reset for next batch
                    count <= 3'd0;
                end else begin
                    // Store current data and increment count
                    data_reg[count] <= data_in;
                    count <= count + 3'd1;
                end
            end
        end
    end

endmodule