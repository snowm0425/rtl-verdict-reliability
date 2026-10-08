module cla_16bit (
    input [15:0] A,
    input [15:0] B,
    input Cin,
    output [15:0] S,
    output Cout
);
    wire [15:0] G;
    wire [15:0] P;
    wire [3:1] C;

    // Generate 4-bit CLA instances
    genvar i;
    generate
        for (i = 0; i < 4; i = i + 1) begin : gen_cla_4bit
            cla_4bit cla_inst (
                .A(A[(i+1)*4-1:i*4]),
                .B(B[(i+1)*4-1:i*4]),
                .Cin(C[i]),
                .S(S[(i+1)*4-1:i*4]),
                .Cout(G[(i+1)*4-1:i*4])
            );
            assign P[(i+1)*4-1:i*4] = (i == 0) ? {4{1'b1}} : {4{P[(i+1)*4-1] & P[(i)*4-1] & P[(i-1)*4-1] & P[(i-2)*4-1]}};
        end
    endgenerate

    // Generate carry signals
    assign C[1] = G[3] | (P[3] & Cin);
    assign C[2] = G[7] | (P[7] & C[1]);
    assign C[3] = G[11] | (P[11] & C[2]);
    assign Cout = G[15] | (P[15] & C[3]);
endmodule