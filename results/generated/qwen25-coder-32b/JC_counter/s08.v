module JC_counter (
    input clk,          // Clock signal
    input rst_n,        // Active-low reset signal
    output reg [63:0] Q // 64-bit register representing the current count value
);

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        // Reset condition: set Q to 0
        Q <= 64'b0;
    end else begin
        // Update the counter based on the Johnson counter rules
        if (Q[0] == 0) begin
            // Shift right and append 1 at the MSB if the LSB is 0
            Q <= {Q[62:0], 1'b1};
        end else begin
            // Shift right and append 0 at the MSB if the LSB is 1
            Q <= {Q[62:0], 1'b0};
        end
    end
end

endmodule