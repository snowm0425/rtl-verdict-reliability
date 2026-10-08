module adder_8bit (
    input [7:0] a,    // 8-bit input operand A
    input [7:0] b,    // 8-bit input operand B
    input       Cin,  // Carry-in input
    output [7:0] y,   // 8-bit output representing the sum of A and B
    output      Co    // Carry-out output
);

    wire [7:0] carry;

    // Generate 8 full adders using a generate loop
    genvar i;
    generate
        for (i = 0; i < 8; i = i + 1) begin: full_adder_gen
            full_adder fa (
                .a(a[i]),
                .b(b[i]),
                .cin((i == 0) ? Cin : carry[i-1]),
                .sum(y[i]),
                .cout(carry[i])
            );
        end
    endgenerate

    // The last carry bit is the carry-out of the 8-bit adder
    assign Co = carry[7];

endmodule

// Full Adder Module (1-bit)
module full_adder (
    input  a,
    input  b,
    input  cin,
    output sum,
    output cout
);

    assign sum = a ^ b ^ cin;
    assign cout = (a & b) | (cin & (a ^ b));

endmodule

// 16-bit Full Adder Module using two 8-bit adders
module adder_16bit (
    input [15:0] a,    // 16-bit input operand A
    input [15:0] b,    // 16-bit input operand B
    input        Cin,  // Carry-in input
    output [15:0] y,   // 16-bit output representing the sum of A and B
    output       Co    // Carry-out output
);

    wire [7:0] y_low, y_high;
    wire       c_low;

    // Instantiate the first 8-bit adder for the lower 8 bits
    adder_8bit adder_low (
        .a(a[7:0]),
        .b(b[7:0]),
        .Cin(Cin),
        .y(y_low),
        .Co(c_low)
    );

    // Instantiate the second 8-bit adder for the upper 8 bits
    adder_8bit adder_high (
        .a(a[15:8]),
        .b(b[15:8]),
        .Cin(c_low),
        .y(y_high),
        .Co(Co)
    );

    // Combine the lower and upper 8-bit results
    assign y[15:8] = y_high;
    assign y[7:0] = y_low;

endmodule