module JC_counter (
    input wire clk,       // Clock signal
    input wire rst_n,     // Active-low reset signal
    output reg [63:0] Q   // 64-bit register for the counter value
);

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        // Reset condition: Set Q to 0
        Q <= 64'b0;
    end else begin
        // Johnson counter logic
        if (Q[0] == 0) begin
            // If the least significant bit is 0, shift right and set MSB to 1
            Q <= {Q[62:0], 1'b1};
        end else begin
            // If the least significant bit is 1, shift right and set MSB to 0
            Q <= {Q[62:0], 1'b0};
        end
    end
end

endmodule