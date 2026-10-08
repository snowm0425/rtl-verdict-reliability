module right_shifter (
    input clk,  // Clock signal used for synchronous operation
    input d,    // Input signal to be right-shifted
    output reg [7:0] q  // Output signal representing the result of the right shift operation
);

// Initialize the q register to 0
initial begin
    q = 8'b0;
end

// On each rising edge of the clock, perform the right shift operation
always @(posedge clk) begin
    // Right shift the contents of q by 1 bit and insert the new input bit d into the most significant position
    q <= {d, q[7:1]};
end

endmodule