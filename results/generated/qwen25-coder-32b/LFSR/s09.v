module LFSR (
    input clk,        // Clock signal
    input rst,        // Active high reset signal
    output reg [3:0] out // 4-bit output representing the current state of the LFSR
);

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            // Initialize the register to zero on reset
            out <= 4'b0000;
        end else begin
            // Calculate the feedback by XORing out[3] and out[2], then inverting the result
            reg feedback;
            feedback = ~(out[3] ^ out[2]);

            // Shift the bits left and insert the feedback into the LSB
            out <= {out[2:0], feedback};
        end
    end

endmodule