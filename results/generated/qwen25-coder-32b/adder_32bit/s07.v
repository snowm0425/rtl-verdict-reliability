module cla_16bit (
    input [15:0] A,
    input [15:0] B,
    input Cin,
    output [15:0] S,
    output Cout
);
    wire [3:0] g;
    wire [3:0] p;
    wire [3:0] c;

    cla_4bit cla4_0 (.A(A[3:0]), .B(B[3:0]), .Cin(Cin), .S(S[3:0]), .Cout(c[0]));
    cla_4bit cla4_1 (.A(A[7:4]), .B(B[7:4]), .Cin(c[0]), .S(S[7:4]), .Cout(c[1]));
    cla_4bit cla4_2 (.A(A[11:8]), .B(B[11:8]), .Cin(c[1]), .S(S[11:8]), .Cout(c[2]));
    cla_4bit cla4_3 (.A(A[15:12]), .B(B[15:12]), .Cin(c[2]), .S(S[15:12]), .Cout(c[3]));

    assign g[0] = c[0];
    assign g[1] = c[1];
    assign g[2] = c[2];
    assign g[3] = c[3];

    assign p[0] = 1'b1;  // Always 1 for 16-bit block
    assign p[1] = 1'b1;
    assign p[2] = 1'b1;
    assign p[3] = 1'b1;

    assign Cout = g[3] | (p[3] & c[2]);
endmodule