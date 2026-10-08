module pe (
    input wire clk,          // Clock signal
    input wire rst,          // Reset signal (active high)
    input wire [31:0] a,     // 32-bit input operand A
    input wire [31:0] b,     // 32-bit input operand B
    output reg [31:0] c      // 32-bit accumulated result
);

// Intermediate wire to store the product of a and b
wire [63:0] product;

// Multiplier to calculate the product of a and b
assign product = a * b;

// Register to store the accumulated result
always @(posedge clk or posedge rst) begin
    if (rst) begin
        c <= 32'b0;  // Reset the accumulator to 0
    end else begin
        c <= c + product[31:0];  // Accumulate the lower 32 bits of the product
    end
end

endmodule