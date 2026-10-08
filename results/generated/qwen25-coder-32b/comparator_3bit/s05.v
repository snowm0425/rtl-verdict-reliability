module comparator_3bit (
    input  [2:0] A,        // First 3-bit input operand
    input  [2:0] B,        // Second 3-bit input operand
    output reg A_greater,  // Output indicating if A > B
    output reg A_equal,    // Output indicating if A == B
    output reg A_less      // Output indicating if A < B
);

always @(*) begin
    // Initialize outputs
    A_greater = 0;
    A_equal   = 0;
    A_less    = 0;

    // Comparison logic
    if (A > B) begin
        A_greater = 1;
    end else if (A == B) begin
        A_equal = 1;
    end else begin
        A_less = 1;
    end
end

endmodule