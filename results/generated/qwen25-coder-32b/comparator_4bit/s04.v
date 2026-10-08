module comparator_4bit (
    input [3:0] A,        // First 4-bit input operand
    input [3:0] B,        // Second 4-bit input operand
    output A_greater,     // A is greater than B
    output A_equal,       // A is equal to B
    output A_less         // A is less than B
);

    // Intermediate signals for subtraction
    wire [3:0] result;    // Result of A - B
    wire borrow;           // Borrow signal from the subtraction

    // Full subtractor module declaration
    module full_subtractor (
        input a,
        input b,
        input borrow_in,
        output diff,
        output borrow_out
    );
        assign diff = a ^ b ^ borrow_in;
        assign borrow_out = (~a & (b | borrow_in)) | (b & borrow_in);
    endmodule

    // Instantiate full subtractors for each bit position
    wire [3:0] borrow_signals;

    // LSB (Least Significant Bit) subtraction
    full_subtractor fs0 (
        .a(A[0]),
        .b(B[0]),
        .borrow_in(1'b1),  // No borrow-in for the LSB
        .diff(result[0]),
        .borrow_out(borrow_signals[0])
    );

    // Middle bit subtractions
    full_subtractor fs1 (
        .a(A[1]),
        .b(B[1]),
        .borrow_in(borrow_signals[0]),
        .diff(result[1]),
        .borrow_out(borrow_signals[1])
    );

    full_subtractor fs2 (
        .a(A[2]),
        .b(B[2]),
        .borrow_in(borrow_signals[1]),
        .diff(result[2]),
        .borrow_out(borrow_signals[2])
    );

    full_subtractor fs3 (
        .a(A[3]),
        .b(B[3]),
        .borrow_in(borrow_signals[2]),
        .diff(result[3]),
        .borrow_out(borrow)
    );

    // Assign outputs based on the subtraction result and borrow signal
    assign A_equal = ~(|result);  // A is equal to B if all bits of result are 0
    assign A_less = borrow;       // A is less than B if a borrow occurs
    assign A_greater = ~(A_equal | A_less);  // A is greater if neither equal nor less

endmodule