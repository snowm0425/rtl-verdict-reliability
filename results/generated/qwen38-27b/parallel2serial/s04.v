module parallel2serial (
    input        clk,
    input        rst_n,
    input  [3:0] d,
    output reg   valid_out,
    output       dout
);

    // Internal registers
    reg [3:0] data;
    reg [1:0] cnt;

    // Assign serial output: MSB of data register
    assign dout = data[3];

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            // Reset state
            data <= 4'b0000;
            cnt  <= 2'b00;
            valid_out <= 1'b0;
        end else begin
            if (cnt == 2'd3) begin
                // Last bit of current sequence
                // Update data with new parallel input
                data <= d;
                // Reset counter to 0 for next sequence
                cnt <= 2'b00;
                // Valid signal high for this cycle (outputting d[3])
                valid_out <= 1'b1;
            end else begin
                // Middle bits of sequence
                // Increment counter
                cnt <= cnt + 1'b1;
                // Valid signal low for subsequent bits
                valid_out <= 1'b0;
                // Shift data left, MSB to LSB
                // Example: 4'b1011 -> 4'b0111 (next cycle dout will be 0, then 1, then 1)
                data <= {data[2:0], data[3]};
            end
        end
    end

endmodule