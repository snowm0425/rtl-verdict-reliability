module parallel2serial (
    input clk,
    input rst_n,
    input [3:0] d,
    output reg valid_out,
    output reg dout
);

    reg [3:0] data;
    reg [1:0] cnt;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            cnt <= 2'd0;
            data <= 4'd0;
            valid_out <= 1'b0;
            dout <= 1'b0;
        end else begin
            if (cnt == 2'd3) begin
                // Last bit of current parallel word has been output
                // Load new data and reset counter
                data <= d;
                cnt <= 2'd0;
                valid_out <= 1'b1;
                dout <= data[3]; // MSB of the new data
            end else begin
                // Increment counter, shift data left
                cnt <= cnt + 1'b1;
                valid_out <= 1'b0;
                // Shift left: MSB moves to LSB position
                data <= {data[2:0], data[3]};
                dout <= data[cnt + 1'b1]; // Next bit to output
            end
        end
    end

endmodule