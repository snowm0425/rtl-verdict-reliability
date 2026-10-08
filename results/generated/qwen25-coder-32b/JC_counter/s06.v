module JC_counter (
    input clk,       // Clock signal
    input rst_n,     // Active-low reset signal
    output reg [63:0] Q  // 64-bit register representing the current count value
);

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        // Reset condition: Set Q to 0
        Q <= 64'b0;
    end else begin
        // Johnson counter logic
        if (Q[0] == 1'b0) begin
            // If the least significant bit (Q[0]) is 0, increment the counter
            Q <= {Q[62:0], 1'b1};
        end else begin
            // If the least significant bit (Q[0]) is 1, decrement the counter
            Q <= {Q[62:0], 1'b0};
        end
    end
end

endmodule