module cla_1bit (
    input  wire A,
    input  wire B,
    input  wire Cin,
    output wire S,
    output wire G, // Generate
    output wire P  // Propagate
);
    assign P = A ^ B;
    assign G = A & B;
    assign S = P ^ Cin;
endmodule

// =============================================================================
// Module: cla_4bit
// Description: 4-bit Carry-Lookahead Adder Block
// =============================================================================
module cla_4bit (
    input  wire [3:0] A,
    input  wire [3:0] B,
    input  wire       Cin,
    output wire [3:0] S,
    output wire       Cout,
    output wire       G_block, // Block Generate
    output wire       P_block  // Block Propagate
);
    wire [3:0] P;
    wire [3:0] G;
    wire [3:0] C; // Internal carries

    // Instantiate 1-bit CLA adders
    cla_1bit bit0 (
        .A(A[0]), .B(B[0]), .Cin(Cin),
        .S(S[0]), .G(G[0]), .P(P[0])
    );
    cla_1bit bit1 (
        .A(A[1]), .B(B[1]), .Cin(C[0]),
        .S(S[1]), .G(G[1]), .P(P[1])
    );
    cla_1bit bit2 (
        .A(A[2]), .B(B[2]), .Cin(C[1]),
        .S(S[2]), .G(G[2]), .P(P[2])
    );
    cla_1bit bit3 (
        .A(A[3]), .B(B[3]), .Cin(C[2]),
        .S(S[3]), .G(G[3]), .P(P[3])
    );

    // Carry Lookahead Logic for 4-bit block
    // C1 = G0 + P0*Cin
    // C2 = G1 + P1*G0 + P1*P0*Cin
    // C3 = G2 + P2*G1 + P2*P1*G0 + P2*P1*P0*Cin
    // C4 (Cout) = G3 + P3*G2 + P3*P2*G1 + P3*P2*P1*G0 + P3*P2*P1*P0*Cin

    assign C[0] = G[0] | (P[0] & Cin);
    assign C[1] = G[1] | (P[1] & G[0]) | (P[1] & P[0] & Cin);
    assign C[2] = G[2] | (P[2] & G[1]) | (P[2] & P[1] & G[0]) | (P[2] & P[1] & P[0] & Cin);
    assign Cout = G[3] | (P[3] & G[2]) | (P[3] & P[2] & G[1]) | (P[3] & P[2] & P[1] & G[0]) | (P[3] & P[2] & P[1] & P[0] & Cin);

    // Block Generate and Propagate
    assign G_block = G[3] | (P[3] & G[2]) | (P[3] & P[2] & G[1]) | (P[3] & P[2] & P[1] & G[0]);
    assign P_block = P[3] & P[2] & P[1] & P[0];

endmodule

// =============================================================================
// Module: cla_16bit
// Description: 16-bit Carry-Lookahead Adder Block
// Composed of four 4-bit CLA blocks
// =============================================================================
module cla_16bit (
    input  wire [15:0] A,
    input  wire [15:0] B,
    input  wire        Cin,
    output wire [15:0] S,
    output wire        Cout,
    output wire        G_block, // 16-bit Block Generate
    output wire        P_block  // 16-bit Block Propagate
);
    wire [3:0] S0, S1, S2, S3;
    wire       C1, C2, C3;
    wire       G0, G1, G2, G3;
    wire       P0, P1, P2, P3;

    // Instantiate four 4-bit CLA blocks
    cla_4bit block0 (
        .A(A[3:0]),
        .B(B[3:0]),
        .Cin(Cin),
        .S(S0),
        .Cout(C1),
        .G_block(G0),
        .P_block(P0)
    );

    cla_4bit block1 (
        .A(A[7:4]),
        .B(B[7:4]),
        .Cin(C1),
        .S(S1),
        .Cout(C2),
        .G_block(G1),
        .P_block(P1)
    );

    cla_4bit block2 (
        .A(A[11:8]),
        .B(B[11:8]),
        .Cin(C2),
        .S(S2),
        .Cout(C3),
        .G_block(G2),
        .P_block(P2)
    );

    cla_4bit block3 (
        .A(A[15:12]),
        .B(B[15:12]),
        .Cin(C3),
        .S(S3),
        .Cout(Cout),
        .G_block(G3),
        .P_block(P3)
    );

    // Combine outputs
    assign S[3:0]   = S0;
    assign S[7:4]   = S1;
    assign S[11:8]  = S2;
    assign S[15:12] = S3;

    // 16-bit Block Generate and Propagate
    // G16 = G3 + P3*G2 + P3*P2*G1 + P3*P2*P1*G0
    // P16 = P3 & P2 & P1 & P0
    assign G_block = G3 | (P3 & G2) | (P3 & P2 & G1) | (P3 & P2 & P1 & G0);
    assign P_block = P3 & P2 & P1 & P0;

endmodule

// =============================================================================
// Module: adder_32bit
// Description: 32-bit Carry-Lookahead Adder
// Top-level module composed of two 16-bit CLA blocks
// =============================================================================
module adder_32bit (
    input  wire [32:1] A,
    input  wire [32:1] B,
    output wire [32:1] S,
    output wire        C32
);
    // Internal wires for carry between 16-bit blocks
    wire C16;
    wire G_low, G_high;
    wire P_low, P_high;

    // Map the 32-bit input to 16-bit chunks
    // A[1] is LSB, A[16] is the boundary, A[32] is MSB
    // Lower 16 bits: A[16:1]
    // Upper 16 bits: A[32:17]
    wire [15:0] A_low  = A[16:1];
    wire [15:0] B_low  = B[16:1];
    wire [15:0] A_high = A[32:17];
    wire [15:0] B_high = B[32:17];

    // Instantiate lower 16-bit CLA
    cla_16bit lower_adder (
        .A(A_low),
        .B(B_low),
        .Cin(1'b0), // No carry-in for LSB
        .S(S[16:1]),
        .Cout(C16),
        .G_block(G_low),
        .P_block(P_low)
    );

    // Instantiate upper 16-bit CLA
    cla_16bit upper_adder (
        .A(A_high),
        .B(B_high),
        .Cin(C16),
        .S(S[32:17]),
        .Cout(C32),
        .G_block(G_high),
        .P_block(P_high)
    );

endmodule