module up_down_counter (
    input wire clk,          // Clock signal
    input wire reset,        // Reset signal
    input wire up_down,      // Control signal for direction
    output reg [15:0] count  // 16-bit counter output
);

// Synchronous process triggered by the rising edge of the clock signal
always @(posedge clk) begin
    if (reset) begin
        // If reset is active, set count to 0
        count <= 16'b0;
    end else begin
        // Determine the counting direction based on the up_down signal
        if (up_down) begin
            // If up_down is 1, increment the counter
            count <= count + 1;
        end else begin
            // If up_down is 0, decrement the counter
            count <= count - 1;
        end
    end
end

endmodule