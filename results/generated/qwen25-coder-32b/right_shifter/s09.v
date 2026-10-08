module right_shifter (
    input clk,  // Clock signal
    input d,    // Input signal to be right-shifted
    output reg [7:0] q  // Output signal representing the result of the right shift operation
);

    // Initialize the register q to 0
    initial begin
        q = 8'b0;
    end

    // On each rising edge of the clock, perform the right shift operation
    always @(posedge clk) begin
        // Right shift the contents of the register q by 1 bit
        q <= (q >> 1);
        // Insert the new input bit d into the most significant position of the register
        q[7] <= d;
    end

endmodule