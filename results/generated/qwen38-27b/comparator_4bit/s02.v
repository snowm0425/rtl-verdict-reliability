module comparator_4bit (
    input  [3:0] A,
    input  [3:0] B,
    output       A_greater,
    output       A_equal,
    output       A_less
);

    // Perform subtraction A - B
    // In binary, A - B is equivalent to A + (~B) + 1
    // The borrow out (from the MSB) indicates if A < B
    wire [4:0] sub_result; // 5-bit to capture borrow out
    wire [3:0] diff;
    wire       borrow_out;

    // sub_result[4] is the borrow out (1 if borrow occurred, i.e., A < B)
    // sub_result[3:0] is the difference
    assign sub_result = {1'b0, A} - {1'b0, B};
    assign borrow_out = sub_result[4];
    assign diff = sub_result[3:0];

    // A_less: borrow occurred during subtraction
    assign A_less = borrow_out;

    // A_equal: difference is zero
    assign A_equal = (diff == 4'd0);

    // A_greater: no borrow and difference is non-zero
    assign A_greater = ~borrow_out & ~A_equal;

endmodule