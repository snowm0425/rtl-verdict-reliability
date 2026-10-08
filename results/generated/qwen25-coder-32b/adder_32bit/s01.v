module cla_16bit (
    input  [15:1] A,
    input  [15:1] B,
    input         Cin,
    output [15:1] S,
    output        Cout
);

    // Generate and propagate signals
    wire [15:1] G;
    wire [15:1] P;
    
    // Internal carry signals
    wire [15:0] C;
    
    genvar i;
    generate
        for (i = 1; i <= 15; i = i + 1) begin : generate_g_and_p
            assign G[i] = A[i] & B[i];
            assign P[i] = A[i] | B[i];
        end
    endgenerate
    
    // Carry lookahead logic
    assign C[0] = Cin;
    assign C[1] = G[1] | (P[1] & C[0]);
    assign C[2] = G[2] | (P[2] & C[1]);
    assign C[3] = G[3] | (P[3] & C[2]);
    assign C[4] = G[4] | (P[4] & C[3]);
    assign C[5] = G[5] | (P[5] & C[4]);
    assign C[6] = G[6] | (P[6] & C[5]);
    assign C[7] = G[7] | (P[7] & C[6]);
    assign C[8] = G[8] | (P[8] & C[7]);
    assign C[9] = G[9] | (P[9] & C[8]);
    assign C[10] = G[10] | (P[10] & C[9]);
    assign C[11] = G[11] | (P[11] & C[10]);
    assign C[12] = G[12] | (P[12] & C[11]);
    assign C[13] = G[13] | (P[13] & C[12]);
    assign C[14] = G[14] | (P[14] & C[13]);
    assign C[15] = G[15] | (P[15] & C[14]);
    
    // Sum outputs
    generate
        for (i = 1; i <= 15; i = i + 1) begin : generate_sum
            assign S[i] = A[i] ^ B[i] ^ C[i-1];
        end
    endgenerate
    
    // Final carry out
    assign Cout = C[15];
    
endmodule