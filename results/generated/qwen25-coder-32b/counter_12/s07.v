module counter_12 (
    input wire rst_n,      // Reset signal (active low)
    input wire clk,        // Clock signal
    input wire valid_count,// Signal to enable counting
    output reg [3:0] out   // 4-bit output representing the current count value
);

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        // Reset the counter to 0 when reset is active low
        out <= 4'b0000;
    end else if (valid_count) begin
        // Increment the counter when valid_count is high
        if (out == 4'd11) begin
            // Wrap around to 0 when reaching the maximum count value of 11
            out <= 4'b0000;
        end else begin
            // Increment the counter
            out <= out + 1;
        end
    end
    // If valid_count is low, the counter remains unchanged
end

endmodule