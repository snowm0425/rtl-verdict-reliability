module pe (
    input wire clk,          // Clock signal
    input wire rst,          // Reset signal (active high)
    input wire [31:0] a,     // 32-bit input operand A
    input wire [31:0] b,     // 32-bit input operand B
    output reg [31:0] c      // 32-bit output representing the accumulated result
);

    // Register to store the partial sum (accumulated result)
    reg [63:0] partial_sum;  // Use 64-bit to prevent overflow during multiplication

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            // Reset the partial sum to 0 on reset
            partial_sum <= 64'b0;
            // Reset the output c to 0 on reset
            c <= 32'b0;
        end else begin
            // Calculate the product of a and b
            wire [63:0] product = a * b;
            // Add the product to the partial sum
            partial_sum <= partial_sum + product;
            // Update the output c with the lower 32 bits of the partial sum
            c <= partial_sum[31:0];
        end
    end

endmodule