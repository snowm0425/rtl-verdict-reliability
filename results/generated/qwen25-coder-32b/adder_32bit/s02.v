module cla_16bit (
    input [15:0] A,
    input [15:0] B,
    input C_in,
    output [15:0] S,
    output C_out
);

    wire [3:0] G;
    wire [3:0] P;
    wire C0, C4, C8, C12;

    // Instantiate four 4-bit CLA blocks
    cla_4bit cla0 (
        .A(A[3:0]),
        .B(B[3:0]),
        .C_in(C_in),
        .S(S[3:0]),
        .C_out(C4),
        .G(G[0]),
        .P(P[0])
    );

    cla_4bit cla1 (
        .A(A[7:4]),
        .B(B[7:4]),
        .C_in(C4),
        .S(S[7:4]),
        .C_out(C8),
        .G(G[1]),
        .P(P[1])
    );

    cla_4bit cla2 (
        .A(A[11:8]),
        .B(B[11:8]),
        .C_in(C8),
        .S(S[11:8]),
        .C_out(C12),
        .G(G[2]),
        .P(P[2])
    );

    cla_4bit cla3 (
        .A(A[15:12]),
        .B(B[15:12]),
        .C_in(C12),
        .S(S[15:12]),
        .C_out(C_out),
        .G(G[3]),
        .P(P[3])
    );

endmodule