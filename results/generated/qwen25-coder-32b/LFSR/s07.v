module LFSR (
    input wire clk,    // Clock signal
    input wire rst,    // Active high reset signal
    output reg [3:0] out // 4-bit output representing the current state of the LFSR
);

reg feedback; // Internal signal to hold the feedback value

always @(posedge clk or posedge rst) begin
    if (rst) begin
        // Initialize the register to zero on reset
        out <= 4'b0000;
    end else begin
        // Calculate the feedback by XORing out[3] and out[2], then invert the result
        feedback = ~(out[3] ^ out[2]);
        
        // Shift the register left and insert the feedback value at the LSB
        out <= {out[2:0], feedback};
    end
end

endmodule