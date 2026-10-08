module up_down_counter (
    input wire clk,       // Clock signal
    input wire reset,     // Reset signal
    input wire up_down,   // Control signal for counting direction
    output reg [15:0] count // 16-bit output for the current counter value
);

always @(posedge clk) begin
    if (reset) begin
        count <= 16'b0;  // Reset the counter to zero
    end else if (up_down) begin
        count <= count + 1;  // Increment the counter
    end else begin
        count <= count - 1;  // Decrement the counter
    end
end

endmodule