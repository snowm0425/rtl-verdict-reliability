module
module adder_8bit (
    input  [7:0] a,    // 8-bit input operand A
    input  [7:0] b,    // 8-bit input operand B
    input        cin,   // Carry-in input
    output [7:0] y,    // 8-bit output representing the sum of A and B
    output       cout   // Carry-out output
);

    wire [7:0] c;       // Internal carry signals

    // Full adder for each bit
    genvar i;
    generate
        for (i = 0; i < 8; i = i + 1) begin : full_adders
            if (i == 0) begin : first_adder
                full_adder fa (
                    .a(a[i]),
                    .b(b[i]),
                    .cin(cin),
                    .y(y[i]),
                    .cout(c[i])
                );
            end else begin : other_adders
                full_adder fa (
                    .a(a[i]),
                    .b(b[i]),
                    .cin(c[i-1]),
                    .y(y[i]),
                    .cout(c[i])
                );
            end
        end
    endgenerate

    // The last carry-out is the overall carry-out
    assign cout = c[7];

endmodule