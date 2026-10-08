module LFSR (
    input wire clk,         // Clock signal
    input wire rst,         // Active high reset signal
    output reg [3:0] out    // 4-bit output representing the current state of the LFSR
);

always @(posedge clk or posedge rst) begin
    if (rst) begin
        // Reset the register to all zeros
        out <= 4'b0000;
    end else begin
        // Calculate the feedback bit by XORing MSB (out[3]) and second MSB (out[2])
        // and then inverting the result.
        reg feedback;
        feedback = ~(out[3] ^ out[2]);
        
        // Shift the register left and insert the feedback bit at the LSB.
        out <= {out[2:0], feedback};
    end
end

endmodule