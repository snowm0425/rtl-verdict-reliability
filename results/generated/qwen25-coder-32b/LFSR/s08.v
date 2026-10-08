module LFSR (
    input wire clk,          // Clock signal
    input wire rst,          // Active high reset signal
    output reg [3:0] out     // 4-bit output
);

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            // Initialize the register to zero on reset
            out <= 4'b0000;
        end else begin
            // Calculate the feedback value
            reg feedback;
            feedback = ~(out[3] ^ out[2]);
            
            // Shift the register left and insert the feedback at the LSB
            out <= {out[2:0], feedback};
        end
    end

endmodule