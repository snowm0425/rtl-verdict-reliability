module LFSR (
    input clk,          // Clock signal
    input rst,          // Active high reset signal
    output reg [3:0] out // 4-bit output
);

always @(posedge clk or posedge rst) begin
    if (rst) begin
        // Initialize the register to zero on reset
        out <= 4'b0000;
    end else begin
        // Calculate the feedback bit as the inverted XOR of out[3] and out[2]
        reg feedback;
        feedback = ~(out[3] ^ out[2]);
        
        // Shift the register left and insert the feedback bit at the LSB
        out <= {out[2:0], feedback};
    end
end

endmodule