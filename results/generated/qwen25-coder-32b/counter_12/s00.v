module counter_12 (
    input wire rst_n,       // Reset signal (active low)
    input wire clk,         // Clock signal
    input wire valid_count, // Signal to enable counting
    output reg [3:0] out    // 4-bit output representing the current count value
);

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        // If reset is active (rst_n is 0), reset the counter to 0
        out <= 4'b0000;
    end else if (valid_count) begin
        // If valid_count is active (1), increment the counter
        if (out == 4'd11) begin
            // If the counter reaches 11 (4'd11), wrap around to 0
            out <= 4'b0000;
        end else begin
            // Otherwise, increment the counter
            out <= out + 1;
        end
    end
end

endmodule