module comparator_4bit (
    input [3:0] A,          // First 4-bit input operand
    input [3:0] B,          // Second 4-bit input operand
    output reg A_greater,   // Output indicating if A is greater than B
    output reg A_equal,     // Output indicating if A is equal to B
    output reg A_less       // Output indicating if A is less than B
);

    // Intermediate wire to hold the result of subtraction
    wire [3:0] diff;
    // Wire to detect if a borrow occurs during subtraction (A < B)
    wire borrow;

    // Perform the subtraction A - B
    assign diff = A - B;

    // Detect borrow: borrow is 1 if A is less than B
    assign borrow = (A < B);

    // Assign outputs based on the subtraction result and borrow flag
    always @(*) begin
        if (borrow) begin
            A_greater = 0;
            A_equal = 0;
            A_less = 1;
        end else if (diff == 4'b0000) begin
            A_greater = 0;
            A_equal = 1;
            A_less = 0;
        end else begin
            A_greater = 1;
            A_equal = 0;
            A_less = 0;
        end
    end

endmodule