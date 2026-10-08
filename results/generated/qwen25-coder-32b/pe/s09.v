module pe (
    input wire clk,          // Clock signal used for synchronous operations.
    input wire rst,          // Reset signal. Defined as 1 for reset and 0 for reset signal inactive.
    input wire [31:0] a,     // 32-bit input operand A.
    input wire [31:0] b,     // 32-bit input operand B.
    output reg [31:0] c      // 32-bit output representing the accumulated result.
);

    // Internal wire to hold the product of a and b
    wire [63:0] product;

    // Multiplier to compute the product of a and b
    assign product = a * b;

    // Accumulator Register
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            // Reset the accumulator register to 0
            c <= 32'b0;
        end else begin
            // Accumulate the product into the register
            c <= c + product[31:0];
        end
    end

endmodule