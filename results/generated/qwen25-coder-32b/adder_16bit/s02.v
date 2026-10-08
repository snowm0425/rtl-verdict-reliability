module
module adder_8bit (
    input [7:0] a,    // 8-bit input operand A
    input [7:0] b,    // 8-bit input operand B
    input cin,        // Carry-in input
    output [7:0] y,   // 8-bit output representing the sum of A and B
    output cout       // Carry-out output
);
    wire [7:0] carry; // Internal carry signals

    // Generate the sum and carry-out for each bit position
    genvar i;
    generate
        for (i = 0; i < 8; i = i + 1) begin : bit_adder
            if (i == 0) begin
                // For the least significant bit, use the external cin
                full_adder fa (
                    .a(a[i]),
                    .b(b[i]),
                    .cin(cin),
                    .sum(y[i]),
                    .cout(carry[i])
                );
            end else begin
                // For other bits, use the previous bit's carry
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

    // The carry-out of the 8-bit adder is the carry of the most significant bit
    assign cout = carry[7];
endmodule

// 1-bit full adder module
module full_adder (
    input a,          // 1-bit input A
    input b,          // 1-bit input B
    input cin,        // Carry-in input
    output sum,       // Sum output
    output cout       // Carry-out output
);
    assign sum = a ^ b ^ cin;
    assign cout = (a & b) | (b & cin) | (a & cin);
endmodule

// 16-bit full adder module
module adder_16bit (
    input [15:0] a,   // 16-bit input operand A
    input [15:0] b,   // 16-bit input operand B
    input cin,        // Carry-in input
    output [15:0] y,  // 16-bit output representing the sum of A and B
    output cout       // Carry-out output
);
    wire c8;          // Carry-out from the first 8-bit adder

    // Instantiate two 8-bit full adders
    adder_8bit adder_lower (
        .a(a[7:0]),
        .b(b[7:0]),
        .cin(cin),
        .y(y[7:0]),
        .cout(c8)
    );

    adder_8bit adder_upper (
        .a(a[15:8]),
        .b(b[15:8]),
        .cin(c8),
        .y(y[15:8]),
        .cout(cout)
    );
endmodule