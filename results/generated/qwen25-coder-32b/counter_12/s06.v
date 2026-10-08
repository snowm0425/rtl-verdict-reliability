module counter_12 (
    input wire rst_n,       // Reset signal (active low)
    input wire clk,         // Clock signal
    input wire valid_count, // Signal to enable counting
    output reg [3:0] out    // 4-bit output representing the current count value
);

    // Always block for handling the counter logic
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            // Reset condition (active low)
            out <= 4'b0000;
        end else if (valid_count) begin
            // Counting condition
            if (out == 4'd11) begin
                // Wrap around when reaching the maximum count value (4'd11)
                out <= 4'b0000;
            end else begin
                // Increment the counter
                out <= out + 1;
            end
        end
        // If valid_count is 0, the counter remains unchanged
    end

endmodule