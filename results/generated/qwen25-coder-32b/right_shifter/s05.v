module right_shifter (
    input clk,    // Clock signal used for synchronous operation
    input d,      // Input signal to be right-shifted
    output reg [7:0] q  // Output signal representing the result of the right shift operation
);

// Initialize the q register to 0
initial begin
    q = 8'b00000000;
end

// On each rising edge of the clock, perform the right shift and insert the new input bit
always @(posedge clk) begin
    q <= {d, q[7:1]};  // Shift q to the right and insert d into the most significant bit position
end

endmodule