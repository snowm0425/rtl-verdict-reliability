module pe (
    input wire clk,          // Clock signal
    input wire rst,          // Reset signal (active high)
    input wire [31:0] a,     // 32-bit input operand A
    input wire [31:0] b,     // 32-bit input operand B
    output reg [31:0] c      // 32-bit output representing the accumulated result
);

    // Register to store the partial sum (accumulated result)
    reg [63:0] partial_sum; // Using 64-bit to avoid overflow during multiplication

    // Always block to handle clock and reset
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            // Reset condition: set the accumulated result to 0
            partial_sum <= 64'd0;
            c <= 32'd0;
        end else begin
            // Normal operation: accumulate the product of a and b
            partial_sum <= partial_sum + (a * b);
            c <= partial_sum[31:0]; // Assign the lower 32 bits to the output
        end
    end

endmodule