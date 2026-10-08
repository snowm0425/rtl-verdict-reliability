module multi_8bit (
    input clk,            // Clock signal
    input reset,          // Reset signal (active high)
    input  [7:0] A,       // First 8-bit input operand (multiplicand)
    input  [7:0] B,       // Second 8-bit input operand (multiplier)
    output [15:0] product // 16-bit output representing the product (A * B)
);

    reg [15:0] acc;       // Accumulator to store the intermediate product
    reg [7:0] multiplicand; // Copy of multiplicand A
    reg [7:0] multiplier; // Copy of multiplier B
    integer i;             // Loop variable

    // Initialize the accumulator to 0 and copies of A and B
    initial begin
        acc = 16'b0;
        multiplicand = A;
        multiplier = B;
    end

    // Sequential logic to perform the shift-and-add multiplication
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            acc <= 16'b0;
            multiplicand <= A;
            multiplier <= B;
        end else begin
            for (i = 0; i < 8; i = i + 1) begin
                if (multiplier[0]) begin
                    acc <= acc + {8'b0, multiplicand}; // Add the multiplicand if the current bit of multiplier is 1
                end
                multiplicand <= multiplicand << 1; // Shift the multiplicand left by 1 bit
                multiplier <= multiplier >> 1; // Shift the multiplier right by 1 bit
            end
        end
    end

    // Assign the final product
    assign product = acc;

endmodule