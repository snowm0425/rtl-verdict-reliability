module cla_4bit (
    input  wire [3:0] A,
    input  wire [3:0] B,
    input  wire       Cin,
    output wire [3:0] S,
    output wire       C4,
    output wire [3:0] G,  // Generate signals
    output wire [3:0] P   // Propagate signals
);
    // Propagate and Generate signals for each bit
    wire [3:0] P;
    wire [3:0] G;

    assign P = A ^ B;
    assign G = A & B;

    // Carry generation for each bit position
    // C0 = Cin
    // C1 = G[0] | (P[0] & Cin)
    // C2 = G[1] | (P[1] & C1)
    // C3 = G[2] | (P[2] & C2)
    // C4 = G[3] | (P[3] & C3)

    wire C1 = G[0] | (P[0] & Cin);
    wire C2 = G[1] | (P[1] & C1);
    wire C3 = G[2] | (P[2] & C2);
    wire C4 = G[3] | (P[3] & C3);

    // Sum bits
    wire [3:0] S;
    assign S[0] = P[0] ^ Cin;
    assign S[1] = P[1] ^ C1;
    assign S[2] = P[2] ^ C2;
    assign S[3] = P[3] ^ C3;

    // Output generate and propagate for higher-level CLA
    assign G = G;
    assign P = P;
endmodule

// 16-bit Carry-Lookahead Adder Block
// This uses four 4-bit CLA blocks with inter-block carry lookahead
module cla_16bit (
    input  wire [15:0] A,
    input  wire [15:0] B,
    input  wire        Cin,
    output wire [15:0] S,
    output wire        C16,
    output wire [15:0] G,  // Group generate
    output wire [15:0] P   // Group propagate
);
    // Split inputs into four 4-bit groups
    wire [3:0] A0 = A[3:0];
    wire [3:0] A1 = A[7:4];
    wire [3:0] A2 = A[11:8];
    wire [3:0] A3 = A[15:12];

    wire [3:0] B0 = B[3:0];
    wire [3:0] B1 = B[7:4];
    wire [3:0] B2 = B[11:8];
    wire [3:0] B3 = B[15:12];

    // Intermediate signals from 4-bit CLA blocks
    wire [3:0] S0, S1, S2, S3;
    wire       C4_0, C4_1, C4_2, C4_3;
    wire [3:0] G0, P0;
    wire [3:0] G1, P1;
    wire [3:0] G2, P2;
    wire [3:0] G3, P3;

    // Instantiate four 4-bit CLA blocks
    cla_4bit u_cla0 (
        .A   (A0),
        .B   (B0),
        .Cin (Cin),
        .S   (S0),
        .C4  (C4_0),
        .G   (G0),
        .P   (P0)
    );

    cla_4bit u_cla1 (
        .A   (A1),
        .B   (B1),
        .Cin (C4_0),
        .S   (S1),
        .C4  (C4_1),
        .G   (G1),
        .P   (P1)
    );

    cla_4bit u_cla2 (
        .A   (A2),
        .B   (B2),
        .Cin (C4_1),
        .S   (S2),
        .C4  (C4_2),
        .G   (G2),
        .P   (P2)
    );

    cla_4bit u_cla3 (
        .A   (A3),
        .B   (B3),
        .Cin (C4_2),
        .S   (S3),
        .C4  (C4_3),
        .G   (G3),
        .P   (P3)
    );

    // Combine sums
    assign S[3:0]    = S0;
    assign S[7:4]    = S1;
    assign S[11:8]   = S2;
    assign S[15:12]  = S3;

    // Final carry out
    assign C16 = C4_3;

    // Group generate and propagate for this 16-bit block
    // G_group = G3 | (P3 & G2) | (P3 & P2 & G1) | (P3 & P2 & P1 & G0)
    // P_group = P3 & P2 & P1 & P0

    wire G_group;
    wire P_group;

    assign G_group = G3[3] | (P3[3] & G2[3]) | (P3[3] & P2[3] & G1[3]) | (P3[3] & P2[3] & P1[3] & G0[3]);
    assign P_group = P3[3] & P2[3] & P1[3] & P0[3];

    // For simplicity, output the full 16-bit G and P vectors
    // In a proper hierarchical CLA, we'd output group generate/propagate
    // But since the top level just needs the final carry, we can keep it simple
    // However, the spec asks for G and P outputs of 16 bits
    assign G[15:0] = {G3, G2, G1, G0};
    assign P[15:0] = {P3, P2, P1, P0};
endmodule

// 32-bit Carry-Lookahead Adder
module adder_32bit (
    input  wire [31:0] A,
    input  wire [31:0] B,
    output wire [31:0] S,
    output wire        C32
);
    // Split inputs into two 16-bit halves
    wire [15:0] A_lower = A[15:0];
    wire [15:0] A_upper = A[31:16];

    wire [15:0] B_lower = B[15:0];
    wire [15:0] B_upper = B[31:16];

    // Intermediate signals
    wire [15:0] S_lower, S_upper;
    wire        C16_lower;
    wire        C32;
    wire [15:0] G_lower, P_lower;
    wire [15:0] G_upper, P_upper;

    // Instantiate two 16-bit CLA blocks
    cla_16bit u_cla_lower (
        .A   (A_lower),
        .B   (B_lower),
        .Cin (1'b0),
        .S   (S_lower),
        .C16 (C16_lower),
        .G   (G_lower),
        .P   (P_lower)
    );

    cla_16bit u_cla_upper (
        .A   (A_upper),
        .B   (B_upper),
        .Cin (C16_lower),
        .S   (S_upper),
        .C16 (C32),
        .G   (G_upper),
        .P   (P_upper)
    );

    // Combine sums
    assign S[15:0]  = S_lower;
    assign S[31:16] = S_upper;
endmodule