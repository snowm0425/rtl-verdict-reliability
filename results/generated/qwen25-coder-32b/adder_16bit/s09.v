module
module adder_8bit (
    input  [7:0] a,      // 8-bit input operand A
    input  [7:0] b,      // 8-bit input operand B
    input        cin,     // Carry-in input
    output [7:0] y,      // 8-bit output representing the sum of A and B
    output       cout     // Carry-out output
);

    wire [7:0] carry;    // Internal carry signals

    // Instantiate full adders for each bit position
    genvar i;
    generate
        for (i = 0; i < 8; i = i + 1) begin : full_adders
            if (i == 0) begin
                // For the least significant bit, use the cin as the carry-in
                full_adder fa (
                    .a(a[i]),
                    .b(b[i]),
                    .cin(cin),
                    .sum(y[i]),
                    .cout(carry[i])
                );
            end else begin
                // For other bits, use the carry from the previous bit
                full_adder fa (
                    .a(a[i]),
                    .b(b[i]),
                    .cin(carry[i-1]),
                    .sum(y[i]),
                    .cout(carry[i])
                );
            end
        end
    endgenerate

    // The carry-out of the 8-bit adder is the most significant carry bit
    assign cout = carry[7];

endmodule

// Full adder module
module full_adder (
    input  a,            // Input bit A
    input  b,            // Input bit B
    input  cin,          // Carry-in input
    output sum,          // Sum output
    output cout          // Carry-out output
);

    // Sum is the XOR of a, b, and cin
    assign sum = a ^ b ^ cin;

    // Carry-out is the OR of (a AND b), (b AND cin), and (cin AND a)
    assign cout = (a & b) | (b & cin) | (cin & a);

endmodule

// 16-bit full adder module using two 8-bit adders
module adder_16bit (
    input  [15:0] a,     // 16-bit input operand A
    input  [15:0] b,     // 16-bit input operand B
    input         cin,     // Carry-in input
    output [15:0] y,     // 16-bit output representing the sum of A and B
    output        cout     // Carry-out output
);

    wire [7:0] y_low;     // Lower 8 bits of the sum
    wire [7:0] y_high;    // Upper 8 bits of the sum
    wire       cout_low;  // Carry-out from the lower 8-bit adder

    // Instantiate the first 8-bit adder for the lower 8 bits
    adder_8bit adder_low (
        .a(a[7:0]),
        .b(b[7:0]),
        .cin(cin),
        .y(y_low),
        .cout(cout_low)
    );

    // Instantiate the second 8-bit adder for the upper 8 bits
    adder_8bit adder_high (
        .a(a[15:8]),
        .b(b[15:8]),
        .cin(cout_low),
        .y(y_high),
        .cout(cout)
    );

    // Concatenate the lower and upper 8 bits to form the 16-bit sum
    assign y = {y_high, y_low};

endmodule