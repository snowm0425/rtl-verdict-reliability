module up_down_counter (
    input wire clk,        // Clock signal
    input wire reset,      // Reset signal
    input wire up_down,    // Control signal for direction
    output reg [15:0] count // 16-bit output for the counter value
);

// Synchronous process triggered by the rising edge of the clock
always @(posedge clk) begin
    if (reset) begin
        // If reset is active, set the counter to zero
        count <= 16'b0000000000000000;
    end else begin
        // If reset is not active, increment or decrement the counter based on up_down signal
        if (up_down) begin
            // Increment the counter if up_down is high
            count <= count + 1;
        end else begin
            // Decrement the counter if up_down is low
            count <= count - 1;
        end
    end
end

endmodule