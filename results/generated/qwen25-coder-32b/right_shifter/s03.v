module right_shifter (
    input clk,  // Clock signal used for synchronous operation
    input d,    // Input signal to be right-shifted
    output reg [7:0] q  // Output signal representing the result of the right shift operation
);

// Initialize the register q to 0
initial begin
    q = 8'b00000000;  // 8-bit register initialized to 0
end

// Synchronous process on the rising edge of the clock
always @(posedge clk) begin
    // Right shift the contents of q by 1 bit and insert the new input bit d into the most significant position
    q <= {d, q[7:1]};
end

endmodule