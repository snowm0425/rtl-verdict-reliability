module LFSR (
    input wire clk,    // Clock signal
    input wire rst,    // Active high reset signal
    output reg [3:0] out // 4-bit output
);

// Internal signals
reg feedback;

// Feedback calculation
assign feedback = ~(out[3] ^ out[2]);

// Sequential block to handle shifting and resetting
always @(posedge clk) begin
    if (rst) begin
        out <= 4'b0000; // Initialize the register to zero on reset
    end else begin
        out <= {out[2:0], feedback}; // Shift left and insert feedback at LSB
    end
end

endmodule