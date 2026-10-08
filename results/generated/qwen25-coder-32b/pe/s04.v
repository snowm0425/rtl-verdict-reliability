module pe (
    input wire clk,          // Clock signal
    input wire rst,          // Reset signal (active high)
    input wire [31:0] a,     // 32-bit input operand A
    input wire [31:0] b,     // 32-bit input operand B
    output reg [31:0] c      // 32-bit output representing the accumulated result
);

    // Register to store the accumulated result
    reg [63:0] acc_reg;  // Using 64-bit to prevent overflow during multiplication

    // On the positive edge of the clock signal or the positive edge of the reset signal
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            // If reset is high, set the accumulator to 0
            acc_reg <= 64'b0;
            c <= 32'b0;
        end else begin
            // Multiply a and b, and add the result to the accumulator
            acc_reg <= acc_reg + ($signed(a) * $signed(b));
            // Assign the lower 32 bits of the accumulator to the output c
            c <= acc_reg[31:0];
        end
    end

endmodule