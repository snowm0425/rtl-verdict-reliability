module comparator_3bit (
    input  [2:0] A,       // First 3-bit input operand
    input  [2:0] B,       // Second 3-bit input operand
    output reg   A_greater, // A is greater than B
    output reg   A_equal,   // A is equal to B
    output reg   A_less     // A is less than B
);

always @(*) begin
    // Initialize outputs to 0
    A_greater = 0;
    A_equal   = 0;
    A_less    = 0;

    // Compare A and B
    if (A > B) begin
        A_greater = 1;
    end else if (A == B) begin
        A_equal = 1;
    end else begin
        A_less = 1;
    end
end

endmodule