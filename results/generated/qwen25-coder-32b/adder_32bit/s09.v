module cla_4bit (
    input [3:0] A,
    input [3:0] B,
    input G_in,
    output [3:0] S,
    output C4
);
    wire [2:0] G;
    wire [2:0] P;
    
    cla_cell c0 (.G_in(G_in), .P_in(1'b1), .A(A[0]), .B(B[0]), .G_out(G[0]), .P_out(P[0]), .S(S[0]));
    cla_cell c1 (.G_in(G[0]), .P_in(P[0]), .A(A[1]), .B(B[1]), .G_out(G[1]), .P_out(P[1]), .S(S[1]));
    cla_cell c2 (.G_in(G[1]), .P_in(P[1]), .A(A[2]), .B(B[2]), .G_out(G[2]), .P_out(P[2]), .S(S[2]));
    cla_cell c3 (.G_in(G[2]), .P_in(P[2]), .A(A[3]), .B(B[3]), .G_out(), .P_out(), .S(S[3]));
    
    assign C4 = G[2] | (P[2] & G[1]) | (P[2] & P[1] & G[0]) | (P[2] & P[1] & P[0] & G_in);
endmodule