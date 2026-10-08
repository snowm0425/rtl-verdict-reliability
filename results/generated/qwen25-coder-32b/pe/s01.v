module pe (
    input clk,              // Clock signal
    input rst,              // Reset signal (active high)
    input [31:0] a,         // 32-bit input operand A
    input [31:0] b,         // 32-bit input operand B
    output reg [31:0] c     // 32-bit accumulated result
);

    // Internal wire to hold the product of a and b
    wire [63:0] product;

    // Multiplication of a and b
    assign product = a * b;

    // Always block for synchronous operations
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            // Reset condition: set the accumulator to 0
            c <= 32'b0;
        end else begin
            // Accumulate the product into the register c
            c <= c + product[31:0];
        end
    end

endmodule