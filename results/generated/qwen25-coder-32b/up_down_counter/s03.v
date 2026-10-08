module up_down_counter (
    input wire clk,        // Clock signal
    input wire reset,      // Reset signal
    input wire up_down,    // Control signal to determine counting direction
    output reg [15:0] count // 16-bit output representing the current counter value
);

always @(posedge clk or posedge reset) begin
    if (reset) begin
        // Reset the counter to zero when reset signal is active
        count <= 16'b0000000000000000;
    end else begin
        // Increment or decrement the counter based on the up_down signal
        if (up_down) begin
            // Increment the counter
            count <= count + 1;
        end else begin
            // Decrement the counter
            count <= count - 1;
        end
    end
end

endmodule