module LFSR (
    input clk,      // Clock signal
    input rst,      // Active high reset signal
    output [3:0] out // 4-bit output representing the current state of the LFSR
);

// Register to hold the current state of the LFSR
reg [3:0] lfsr_reg;

// Feedback signal calculation
wire feedback;

// Feedback is the inverted XOR of the MSB (out[3]) and the second MSB (out[2])
assign feedback = ~(lfsr_reg[3] ^ lfsr_reg[2]);

// Sequential logic to update the LFSR state
always @(posedge clk or posedge rst) begin
    if (rst) begin
        // Initialize the register to zero on reset
        lfsr_reg <= 4'b0000;
    end else begin
        // Shift left and insert the feedback at the LSB
        lfsr_reg <= {lfsr_reg[2:0], feedback};
    end
end

// Assign the current state of the LFSR to the output
assign out = lfsr_reg;

endmodule