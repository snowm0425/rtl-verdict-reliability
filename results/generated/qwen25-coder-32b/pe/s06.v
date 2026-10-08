module pe (
    input wire clk,          // Clock signal
    input wire rst,          // Reset signal (active high)
    input wire [31:0] a,     // 32-bit input operand A
    input wire [31:0] b,     // 32-bit input operand B
    output reg [31:0] c      // 32-bit output representing the accumulated result
);

// Internal register to store the partial sum
reg [31:0] accumulator;

// Always block to handle the multiplication and accumulation
always @(posedge clk or posedge rst) begin
    if (rst) begin
        // Reset condition: set the accumulator to 0
        accumulator <= 32'b0;
    end else begin
        // Accumulation: add the product of a and b to the accumulator
        accumulator <= accumulator + (a * b);
    end
end

// Assign the accumulator value to the output c
assign c = accumulator;

endmodule