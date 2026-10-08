module adder_8bit (
    input  [7:0] a,    // 8-bit input operand A
    input  [7:0] b,    // 8-bit input operand B
    input        cin,   // Carry-in
    output [7:0] y,    // 8-bit output representing the sum of A and B
    output       cout   // Carry-out
);

    wire [7:0] internal_carry;

    // Generate the 8-bit adder using a for loop
    genvar i;
    generate
        for (i = 0; i < 8; i = i + 1) begin : each_full_adder
            // Instantiate a 1-bit full adder for each bit
            full_adder fa (
                .a(a[i]),
                .b(b[i]),
                .cin((i == 0) ? cin : internal_carry[i-1]),
                .y(y[i]),
                .cout(internal_carry[i])
            );
        end
    endgenerate

    // Assign the last internal carry as the carry-out
    assign cout = internal_carry[7];

endmodule

// Module for a 1-bit full adder
module full_adder (
    input  a,    // 1-bit input A
    input  b,    // 1-bit input B
    input  cin,  // Carry-in
    output y,    // 1-bit output representing the sum of A, B, and Cin
    output cout  // Carry-out
);

    // Sum output is the XOR of A, B, and Cin
    assign y = a ^ b ^ cin;

    // Carry-out is the OR of the following conditions:
    // 1. A and B
    // 2. B and Cin
    // 3. A and Cin
    assign cout = (a & b) | (b & cin) | (a & cin);

endmodule

// Module for a 16-bit full adder using two 8-bit full adders
module adder_16bit (
    input  [15:0] a,    // 16-bit input operand A
    input  [15:0] b,    // 16-bit input operand B
    input         cin,   // Carry-in
    output [15:0] y,    // 16-bit output representing the sum of A and B
    output        cout   // Carry-out
);

    // Instantiate two 8-bit full adders
    adder_8bit adder_low (
        .a(a[7:0]),
        .b(b[7:0]),
        .cin(cin),
        .y(y[7:0]),
        .cout(cin_mid)
    );

    adder_8bit adder_high (
        .a(a[15:8]),
        .b(b[15:8]),
        .cin(cin_mid),
        .y(y[15:8]),
        .cout(cout)
    );

endmodule