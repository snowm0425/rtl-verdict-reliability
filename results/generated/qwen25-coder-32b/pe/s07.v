module pe (
    input wire clk,        // Clock signal
    input wire rst,        // Reset signal (active high)
    input wire [31:0] a,   // 32-bit input operand A
    input wire [31:0] b,   // 32-bit input operand B
    output reg [31:0] c    // 32-bit output representing the accumulated result
);

    // Register to store the accumulated result
    reg [63:0] acc;  // Using 64-bit to prevent overflow during multiplication

    // Always block to handle the accumulation logic
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            // Reset the accumulator to 0 on reset
            acc <= 64'b0;
            c <= 32'b0;  // Ensure the output is also reset to 0
        end else begin
            // Multiply a and b, and add the result to the accumulator
            acc <= acc + ($signed(a) * $signed(b));
            // Update the output c with the lower 32 bits of the accumulator
            c <= acc[31:0];
        end
    end

endmodule