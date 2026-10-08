module cla_16bit (
    input  wire [15:0] A,    // 16-bit input operand A
    input  wire [15:0] B,    // 16-bit input operand B
    input  wire        C_in,  // Carry-in to the 16-bit block
    output wire [15:0] S,    // 16-bit output representing the sum
    output wire        C_out  // Carry-out from the 16-bit block
);

    // Generate signals for propagate and generate
    wire [15:0] P, G;
    wire [15:0] C;

    // Generate and propagate signals
    genvar i;
    generate
        for (i = 0; i < 16; i = i + 1) begin : gen_PG
            assign P[i] = A[i] | B[i];
            assign G[i] = A[i] & B[i];
        end
    endgenerate

    // Calculate the carry signals
    assign C[0] = G[0] | (P[0] & C_in);
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

    // Calculate the sum
    assign S = A ^ B ^ C_in;

    // Assign the carry-out
    assign C_out = C[15];

endmodule