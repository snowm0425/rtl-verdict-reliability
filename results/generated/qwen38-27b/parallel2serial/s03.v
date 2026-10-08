module parallel2serial (
    input wire clk,
    input wire rst_n,
    input wire [3:0] d,
    output reg valid_out,
    output wire dout
);

    // Internal registers
    reg [1:0] cnt;
    reg [3:0] data;

    // dout is the MSB of the internal data register
    assign dout = data[3];

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            cnt <= 2'd0;
            data <= 4'b0000;
            valid_out <= 1'b0;
        end else begin
            if (cnt == 2'd3) begin
                // Last bit of current group has been processed.
                // Load new parallel data.
                data <= d;
                // Reset counter to start of new group.
                cnt <= 2'd0;
                // Assert valid to indicate new group's MSB is available.
                valid_out <= 1'b1;
            end else begin
                // Shift data left.
                // Spec: "shifts the data register (data) one bit to the left, 
                // with the most significant bit shifted to the least significant bit."
                // This is a rotate left.
                data <= {data[2:0], data[3]};
                
                // Increment counter.
                cnt <= cnt + 1'b1;
                
                // Deassert valid as we are in the middle of the group.
                valid_out <= 1'b0;
            end
        end
    end

endmodule