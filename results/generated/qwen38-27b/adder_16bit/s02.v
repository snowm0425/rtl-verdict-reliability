module adder_8bit (
    input  [7:0] a,
    input  [7:0] b,
    input        Cin,
    output [7:0] y,
    output       Co
);
    wire [7:0] carry;
    wire [7:0] sum;

    // Generate 8 full adders
    genvar i;
    generate
        for (i = 0; i < 8; i = i + 1) begin : gen_fa
            wire c_out;
            full_adder fa (
                .a    (a[i]),
                .b    (b[i]),
                .Cin  (i == 0 ? Cin : carry[i-1]),
                .sum  (sum[i]),
                .Cout (c_out)
            );
            assign carry[i] = c_out;
        end
    endgenerate

    assign y  = sum;
    assign Co = carry[7];

endmodule

module full_adder (
    input  a,
    input  b,
    input  Cin,
    output sum,
    output Cout
);
    assign sum  = a ^ b ^ Cin;
    assign Cout = (a & b) | (a & Cin) | (b & Cin);
endmodule

module adder_16bit (
    input  [15:0] a,
    input  [15:0] b,
    input         Cin,
    output [15:0] y,
    output        Co
);
    wire [7:0] low_sum;
    wire [7:0] high_sum;
    wire       low_cout;

    // Lower 8-bit adder
    adder_8bit adder_low (
        .a    (a[7:0]),
        .b    (b[7:0]),
        .Cin  (Cin),
        .y    (low_sum),
        .Co   (low_cout)
    );

    // Upper 8-bit adder
    adder_8bit adder_high (
        .a    (a[15:8]),
        .b    (b[15:8]),
        .Cin  (low_cout),
        .y    (high_sum),
        .Co   (Co)
    );

    assign y = {high_sum, low_sum};

endmodule