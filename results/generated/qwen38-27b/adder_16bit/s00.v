module adder_8bit (
    input  [7:0] a,
    input  [7:0] b,
    input        Cin,
    output [7:0] y,
    output       Co
);
    // Internal carry signals
    wire [6:0] carries;

    // Bit 0
    wire sum0 = a[0] ^ b[0] ^ Cin;
    wire c0   = (a[0] & b[0]) | (a[0] & Cin) | (b[0] & Cin);

    // Bit 1
    wire sum1 = a[1] ^ b[1] ^ c0;
    wire c1   = (a[1] & b[1]) | (a[1] & c0) | (b[1] & c0);

    // Bit 2
    wire sum2 = a[2] ^ b[2] ^ c1;
    wire c2   = (a[2] & b[2]) | (a[2] & c1) | (b[2] & c1);

    // Bit 3
    wire sum3 = a[3] ^ b[3] ^ c2;
    wire c3   = (a[3] & b[3]) | (a[3] & c2) | (b[3] & c2);

    // Bit 4
    wire sum4 = a[4] ^ b[4] ^ c3;
    wire c4   = (a[4] & b[4]) | (a[4] & c3) | (b[4] & c3);

    // Bit 5
    wire sum5 = a[5] ^ b[5] ^ c4;
    wire c5   = (a[5] & b[5]) | (a[5] & c4) | (b[5] & c4);

    // Bit 6
    wire sum6 = a[6] ^ b[6] ^ c5;
    wire c6   = (a[6] & b[6]) | (a[6] & c5) | (b[6] & c5);

    // Bit 7
    wire sum7 = a[7] ^ b[7] ^ c6;
    wire Co   = (a[7] & b[7]) | (a[7] & c6) | (b[7] & c6);

    assign y[0] = sum0;
    assign y[1] = sum1;
    assign y[2] = sum2;
    assign y[3] = sum3;
    assign y[4] = sum4;
    assign y[5] = sum5;
    assign y[6] = sum6;
    assign y[7] = sum7;

endmodule

module adder_16bit (
    input  [15:0] a,
    input  [15:0] b,
    input         Cin,
    output [15:0] y,
    output        Co
);
    // Internal carry from the lower 8-bit adder
    wire carry_mid;

    // Lower 8-bit adder: bits [7:0]
    adder_8bit u_lower (
        .a    (a[7:0]),
        .b    (b[7:0]),
        .Cin  (Cin),
        .y    (y[7:0]),
        .Co   (carry_mid)
    );

    // Upper 8-bit adder: bits [15:8]
    adder_8bit u_upper (
        .a    (a[15:8]),
        .b    (b[15:8]),
        .Cin  (carry_mid),
        .y    (y[15:8]),
        .Co   (Co)
    );

endmodule