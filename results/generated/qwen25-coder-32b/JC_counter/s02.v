module JC_counter (
    input clk,      // Clock signal used for synchronous operation
    input rst_n,    // Active-low reset signal to initialize the counter
    output reg [63:0] Q // 64-bit register representing the current count value
);

// Synchronous logic to update the counter value
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        // If the reset signal is low, set the counter value to 0
        Q <= 64'b0;
    end else begin
        // Update the counter value based on the current state
        if (Q[0] == 1'b0) begin
            // If the least significant bit is 0, shift right and append 1 at MSB
            Q <= {Q[62:0], 1'b1};
        end else begin
            // If the least significant bit is 1, shift right and append 0 at MSB
            Q <= {Q[62:0], 1'b0};
        end
    end
end

endmodule