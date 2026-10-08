module right_shifter (
    input clk,  // Clock signal used for synchronous operation
    input d,    // Input signal to be right-shifted
    output [7:0] q  // Output signal representing the result of the right shift operation
);

    reg [7:0] q;  // 8-bit register

    // Initialize the register to 0
    initial begin
        q = 8'b00000000;
    end

    // Right shift operation on the rising edge of the clock
    always @(posedge clk) begin
        q <= {d, q[7:1]};  // Shift right and insert the new input bit d into the MSB position
    end

endmodule