module comparator_4bit (
    input [3:0] A,        // First 4-bit input operand
    input [3:0] B,        // Second 4-bit input operand
    output reg A_greater, // Output indicating if A is greater than B
    output reg A_equal,   // Output indicating if A is equal to B
    output reg A_less     // Output indicating if A is less than B
);

    // Temporary variables to hold the subtraction result and borrow
    wire [3:0] diff;
    wire borrow;

    // Perform subtraction A - B
    // We use a full subtractor for each bit position
    full_subtractor fs0 (
        .A(A[0]),
        .B(B[0]),
        .Borrow_in(1'b1), // Initial borrow is set to 1 for subtraction
        .Diff(diff[0]),
        .Borrow_out(borrow)
    );

    full_subtractor fs1 (
        .A(A[1]),
        .B(B[1]),
        .Borrow_in(borrow),
        .Diff(diff[1]),
        .Borrow_out(borrow)
    );

    full_subtractor fs2 (
        .A(A[2]),
        .B(B[2]),
        .Borrow_in(borrow),
        .Diff(diff[2]),
        .Borrow_out(borrow)
    );

    full_subtractor fs3 (
        .A(A[3]),
        .B(B[3]),
        .Borrow_in(borrow),
        .Diff(diff[3]),
        .Borrow_out(borrow)
    );

    // Determine the relationship between A and B
    always @(*) begin
        // If borrow is high, A is less than B
        if (borrow)
            A_less = 1'b1;
        else
            A_less = 1'b0;

        // If no borrow and result is zero, A is equal to B
        if (!borrow && (diff == 4'b0000))
            A_equal = 1'b1;
        else
            A_equal = 1'b0;

        // If no borrow and result is non-zero, A is greater than B
        if (!borrow && (diff != 4'b0000))
            A_greater = 1'b1;
        else
            A_greater = 1'b0;
    end

endmodule

// Full subtractor module
module full_subtractor (
    input A,
    input B,
    input Borrow_in,
    output Diff,
    output Borrow_out
);

    // Difference calculation
    assign Diff = A ^ B ^ Borrow_in;

    // Borrow calculation
    assign Borrow_out = (~A & B) | (Borrow_in & (~A | B));

endmodule