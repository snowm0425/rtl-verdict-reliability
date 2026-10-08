module counter_12 (
    input wire rst_n,       // Reset signal (active low)
    input wire clk,         // Clock signal
    input wire valid_count, // Signal to enable counting
    output reg [3:0] out    // 4-bit output representing the current count value
);

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            // Reset the counter to 0 when the reset signal is active (rst_n is 0)
            out <= 4'b0000;
        end else if (valid_count) begin
            // Increment the counter if valid_count is 1
            if (out == 4'd11) begin
                // Wrap around and reset to 0 when the maximum count value (4'd11) is reached
                out <= 4'b0000;
            end else begin
                // Increment the counter by 1
                out <= out + 1;
            end
        end
        // If valid_count is 0, the counter remains unchanged
    end

endmodule