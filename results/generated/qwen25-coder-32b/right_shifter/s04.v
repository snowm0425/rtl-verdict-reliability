module right_shifter (
    input clk,  // Clock signal used for synchronous operation
    input d,    // 1-bit input signal to be right-shifted
    output [7:0] q  // 8-bit output signal representing the result of the right shift operation
);

    // Register definition and initialization
    reg [7:0] q;

    // Initialization block
    initial begin
        q = 8'b0;  // Initialize the register to 0
    end

    // Synchronous always block on rising edge of clk
    always @(posedge clk) begin
        // Right shift the contents of q by 1 bit
        q <= (q >> 1);
        // Insert the new input bit d into the most significant position of the register
        q[7] <= d;
    end

endmodule