module up_down_counter (
    input wire clk,         // Clock signal
    input wire reset,       // Reset signal
    input wire up_down,     // Control signal to determine counting direction
    output reg [15:0] count // 16-bit counter output
);

always @(posedge clk or posedge reset) begin
    if (reset) begin
        count <= 16'b0; // Reset the counter to zero when reset is active
    end else begin
        if (up_down) begin
            count <= count + 1; // Increment the counter if up_down is high
        end else begin
            count <= count - 1; // Decrement the counter if up_down is low
        end
    end
end

endmodule