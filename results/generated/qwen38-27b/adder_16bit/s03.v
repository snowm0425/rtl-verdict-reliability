module adder_8bit (
    input  [7:0] a,
    input  [7:0] b,
    input        Cin,
    output [7:0] y,
    output       Co
);
    wire [7:0] sum;
    wire [7:0] carry;

    // Use a ripple-carry adder built from 1-bit full adders
    wire [7:0] carry_internal;

    assign sum = a + b + Cin;
    assign Co  = (a + b + Cin) > 8'hFF;

    // Alternatively, implement explicitly with full adder chain
    // Let's do a proper ripple-carry implementation using 1-bit full adders

    wire [7:0] c;
    assign c[0] = Cin;

    // 1-bit full adder function
    // For bit i:
    //   sum_i = a_i ^ b_i ^ c_i
    //   c_{i+1} = (a_i & b_i) | (a_i & c_i) | (b_i & c_i)

    genvar i;
    generate
        for (i = 0; i < 8; i = i + 1) begin : fa_gen
            wire a_i = a[i];
            wire b_i = b[i];
            wire c_i = c[i];
            wire sum_i = a_i ^ b_i ^ c_i;
            wire c_next = (a_i & b_i) | (a_i & c_i) | (b_i & c_i);

            assign y[i] = sum_i;
            assign c[i+1] = c_next;
        end
    endgenerate

    assign Co = c[8];

endmodule

module adder_16bit (
    input  [15:0] a,
    input  [15:0] b,
    input         Cin,
    output [15:0] y,
    output        Co
);
    wire [7:0] y_low;
    wire       carry_mid;
    wire [7:0] y_high;

    // Lower 8-bit adder
    adder_8bit u_lower (
        .a   (a[7:0]),
        .b   (b[7:0]),
        .Cin (Cin),
        .y   (y_low),
        .Co  (carry_mid)
    );

    // Upper 8-bit adder
    adder_8bit u_upper (
        .a   (a[15:8]),
        .b   (b[15:8]),
        .Cin (carry_mid),
        .y   (y_high),
        .Co  (Co)
    );

    assign y = {y_high, y_low};

endmodule