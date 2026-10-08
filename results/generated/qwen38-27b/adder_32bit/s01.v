module fa_1bit (
    input A,
    input B,
    input Cin,
    output S,
    output Cout
);
    assign S = A ^ B ^ Cin;
    assign Cout = (A & B) | (Cin & (A ^ B));
endmodule

// 4-bit Carry-Lookahead Adder
module cla_4bit (
    input [3:0] A,
    input [3:0] B,
    input Cin,
    output [3:0] S,
    output Cout
);
    wire [3:0] G;
    wire [3:0] P;
    wire [2:0] Cin_int;
    wire Cout_0, Cout_1, Cout_2, Cout_3;

    // Generate and Propagate signals
    assign G = A & B;
    assign P = A ^ B;

    // Carry look-ahead logic
    assign Cin_int[0] = Cin;
    assign Cout_0 = G[0] | (P[0] & Cin);
    assign Cin_int[1] = Cout_0;
    assign Cout_1 = G[1] | (P[1] & Cin_int[1]);
    assign Cin_int[2] = Cout_1;
    assign Cout_2 = G[2] | (P[2] & Cin_int[2]);
    assign Cin_int[3] = Cout_2;
    assign Cout_3 = G[3] | (P[3] & Cin_int[3]);

    // Sum outputs
    assign S[0] = P[0] ^ Cin;
    assign S[1] = P[1] ^ Cin_int[1];
    assign S[2] = P[2] ^ Cin_int[2];
    assign S[3] = P[3] ^ Cin_int[3];

    assign Cout = Cout_3;
endmodule

// 16-bit Carry-Lookahead Adder
module cla_16bit (
    input [15:0] A,
    input [15:0] B,
    input Cin,
    output [15:0] S,
    output Cout
);
    wire [3:0] G_hi, G_lo, G_mid_hi, G_mid_lo;
    wire [3:0] P_hi, P_lo, P_mid_hi, P_mid_lo;
    wire Cout_0, Cout_1, Cout_2, Cout_3;
    wire [15:0] A_lo, A_mid_lo, A_mid_hi, A_hi;
    wire [15:0] B_lo, B_mid_lo, B_mid_hi, B_hi;
    wire [15:0] S_lo, S_mid_lo, S_mid_hi, S_hi;

    // Split inputs into 4-bit groups
    assign A_lo = A[3:0];
    assign A_mid_lo = A[7:4];
    assign A_mid_hi = A[11:8];
    assign A_hi = A[15:12];

    assign B_lo = B[3:0];
    assign B_mid_lo = B[7:4];
    assign B_mid_hi = B[11:8];
    assign B_hi = B[15:12];

    // Instantiate 4-bit CLAs
    cla_4bit cla_lo (
        .A(A_lo),
        .B(B_lo),
        .Cin(Cin),
        .S(S_lo),
        .Cout(Cout_0)
    );

    cla_4bit cla_mid_lo (
        .A(A_mid_lo),
        .B(B_mid_lo),
        .Cin(Cout_0),
        .S(S_mid_lo),
        .Cout(Cout_1)
    );

    cla_4bit cla_mid_hi (
        .A(A_mid_hi),
        .B(B_mid_hi),
        .Cin(Cout_1),
        .S(S_mid_hi),
        .Cout(Cout_2)
    );

    cla_4bit cla_hi (
        .A(A_hi),
        .B(B_hi),
        .Cin(Cout_2),
        .S(S_hi),
        .Cout(Cout_3)
    );

    assign S = {S_hi, S_mid_hi, S_mid_lo, S_lo};
    assign Cout = Cout_3;
endmodule

// 32-bit Carry-Lookahead Adder
module adder_32bit (
    input [31:0] A,
    input [31:0] B,
    output [31:0] S,
    output C32
);
    wire [15:0] A_lo, A_hi;
    wire [15:0] B_lo, B_hi;
    wire [15:0] S_lo, S_hi;
    wire Cout_lo;

    // Split inputs into 16-bit groups
    assign A_lo = A[15:0];
    assign A_hi = A[31:16];

    assign B_lo = B[15:0];
    assign B_hi = B[31:16];

    // Instantiate 16-bit CLAs
    cla_16bit cla_lo (
        .A(A_lo),
        .B(B_lo),
        .Cin(1'b0),
        .S(S_lo),
        .Cout(Cout_lo)
    );

    cla_16bit cla_hi (
        .A(A_hi),
        .B(B_hi),
        .Cin(Cout_lo),
        .S(S_hi),
        .Cout(C32)
    );

    assign S = {S_hi, S_lo};
endmodule