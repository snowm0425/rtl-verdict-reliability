module JC_counter (
    input clk,      // Clock signal used for synchronous operation.
    input rst_n,    // Active-low reset signal to initialize the counter.
    output reg [63:0] Q // 64-bit register representing the current count value.
);

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        // If the reset signal (rst_n) is low, set the counter value (Q) to 0.
        Q <= 64'b0;
    end else begin
        // Otherwise, update the counter based on the value of the least significant bit (Q[0]).
        if (Q[0] == 1'b0) begin
            // If Q[0] is 0, increment the counter by shifting Q[63:1] to the right and appending a 1 at the MSB.
            Q <= {Q[62:0], 1'b1};
        end else begin
            // If Q[0] is 1, decrement the counter by shifting Q[63:1] to the right and appending a 0 at the MSB.
            Q <= {Q[62:0], 1'b0};
        end
    end
end

endmodule