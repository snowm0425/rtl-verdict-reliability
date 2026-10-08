module pe (
    input wire clk,        // Clock signal
    input wire rst,        // Reset signal (active high)
    input wire [31:0] a,   // 32-bit input operand A
    input wire [31:0] b,   // 32-bit input operand B
    output reg [31:0] c    // 32-bit output representing the accumulated result
);

    // Register to store the accumulated result
    reg [31:0] partial_sum;

    // Always block to handle the multiplication and accumulation
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            // Reset condition: set the accumulator to 0
            partial_sum <= 32'b0;
            c <= 32'b0;
        end else begin
            // Normal operation: accumulate the product of a and b
            partial_sum <= partial_sum + (a * b);
            c <= partial_sum;
        end
    end

endmodule