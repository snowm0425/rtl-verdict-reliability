module up_down_counter (
    input wire clk,         // Clock signal
    input wire reset,       // Reset signal
    input wire up_down,     // Control signal for counting direction
    output reg [15:0] count // 16-bit counter output
);

// Synchronous process triggered on the rising edge of the clock
always @(posedge clk) begin
    if (reset) begin
        // Reset the counter to zero if reset is active
        count <= 16'b0;
    end else begin
        // Increment or decrement the counter based on the up_down signal
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