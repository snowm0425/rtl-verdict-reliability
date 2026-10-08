module adder_16bit (
    input  [15:0] a,    // 16-bit input operand A
    input  [15:0] b,    // 16-bit input operand B
    input         cin,  // Carry-in input
    output [15:0] y,    // 16-bit output representing the sum of A and B
    output        cout  // Carry-out output
);

    wire [7:0] y_low;
    wire [7:0] y_high;
    wire       cout_low;
    wire       cout_high;

    // Instantiate the first 8-bit adder for the lower 8 bits
    adder_8bit adder_low (
        .a(a[7:0]),
        .b(b[7:0]),
        .cin(cin),
        .y(y_low),
        .cout(cout_low)
    );

    // Instantiate the second 8-bit adder for the higher 8 bits
    adder_8bit adder_high (
        .a(a[15:8]),
        .b(b[15:8]),
        .cin(cout_low),
        .y(y_high),
        .cout(cout_high)
    );

    // Assign the outputs
    assign y[7:0] = y_low;
    assign y[15:8] = y_high;
    assign cout = cout_high;

endmodule