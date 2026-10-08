module cla_16bit (
    input  [15:0] A,   // 16-bit input A
    input  [15:0] B,   // 16-bit input B
    input         Cin, // Carry-in
    output [15:0] S,   // 16-bit output sum
    output        Cout // Carry-out
);

    // Generate propagate and generate signals
    wire [15:0] p;
    wire [15:0] g;
    assign p = A ^ B;
    assign g = A & B;

    // Generate carry lookahead signals
    wire [15:0] c;
    assign c[0] = Cin;
    assign c[1] = g[0] | (p[0] & c[0]);
    assign c[2] = g[1] | (p[1] & c[1]);
    assign c[3] = g[2] | (p[2] & c[2]);
    assign c[4] = g[3] | (p[3] & c[3]);
    assign c[5] = g[4] | (p[4] & c[4]);
    assign c[6] = g[5] | (p[5] & c[5]);
    assign c[7] = g[6] | (p[6] & c[6]);
    assign c[8] = g[7] | (p[7] & c[7]);
    assign c[9] = g[8] | (p[8] & c[8]);
    assign c[10] = g[9] | (p[9] & c[9]);
    assign c[11] = g[10] | (p[10] & c[10]);
    assign c[12] = g[11] | (p[11] & c[11]);
    assign c[13] = g[12] | (p[12] & c[12]);
    assign c[14] = g[13] | (p[13] & c[13]);
    assign c[15] = g[14] | (p[14] & c[14]);

    // Generate sum
    assign S = p ^ c;

    // Assign carry-out
    assign Cout = c[15];
endmodule