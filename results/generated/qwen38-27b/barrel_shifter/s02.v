module mux2X1 (
    input a,
    input b,
    input sel,
    output y
);
    assign y = sel ? b : a;
endmodule

module barrel_shifter (
    input [7:0] in,
    input [2:0] ctrl,
    output [7:0] out
);

    wire [7:0] stage0;
    wire [7:0] stage1;
    wire [7:0] stage2;

    // Stage 0: shift by 4 if ctrl[2] is high
    // For each bit i, if shifted left by 4: out[i] = in[i-4] if i>=4, else 0? 
    // Wait, we need to think about what kind of shift. The problem says "rotating bits" but then describes shifting.
    // Let me re-read: "A barrel shifter for rotating bits efficiently" but then says "shifts the input in based on the value of the ctrl signal."
    // The implementation says "shifts by 4, 2, or 1 position". For a barrel shifter that can do any rotation 0-7, it's typically a rotate.
    // Let's assume it's a rotate left. For rotate left by n: out[i] = in[(i-n) mod 8]
    // Stage 0 (shift/rotate by 4): if ctrl[2] is 1, rotate left by 4.
    // Rotate left by 4: out[i] = in[(i-4) mod 8]
    // So: out[0] = in[4], out[1] = in[5], out[2] = in[6], out[3] = in[7], out[4] = in[0], out[5] = in[1], out[6] = in[2], out[7] = in[3]
    // Mux selects between original in[i] and rotated value.
    
    wire [7:0] rot4;
    assign rot4[0] = in[4];
    assign rot4[1] = in[5];
    assign rot4[2] = in[6];
    assign rot4[3] = in[7];
    assign rot4[4] = in[0];
    assign rot4[5] = in[1];
    assign rot4[6] = in[2];
    assign rot4[7] = in[3];

    // Stage 1: shift/rotate by 2 if ctrl[1] is high
    // Rotate left by 2: out[i] = in[(i-2) mod 8]
    wire [7:0] rot2;
    assign rot2[0] = stage0[2];
    assign rot2[1] = stage0[3];
    assign rot2[2] = stage0[4];
    assign rot2[3] = stage0[5];
    assign rot2[4] = stage0[6];
    assign rot2[5] = stage0[7];
    assign rot2[6] = stage0[0];
    assign rot2[7] = stage0[1];

    // Stage 2: shift/rotate by 1 if ctrl[0] is high
    // Rotate left by 1: out[i] = in[(i-1) mod 8]
    wire [7:0] rot1;
    assign rot1[0] = stage1[1];
    assign rot1[1] = stage1[2];
    assign rot1[2] = stage1[3];
    assign rot1[3] = stage1[4];
    assign rot1[4] = stage1[5];
    assign rot1[5] = stage1[6];
    assign rot1[6] = stage1[7];
    assign rot1[7] = stage1[0];

    // Muxes for each stage
    // Stage 0: select between in and rot4 based on ctrl[2]
    genvar i;
    generate
        for (i = 0; i < 8; i = i + 1) begin : stage0_gen
            mux2X1 u_mux_s0 (
                .a(in[i]),
                .b(rot4[i]),
                .sel(ctrl[2]),
                .y(stage0[i])
            );
        end
    endgenerate

    // Stage 1: select between stage0 and rot2 based on ctrl[1]
    generate
        for (i = 0; i < 8; i = i + 1) begin : stage1_gen
            mux2X1 u_mux_s1 (
                .a(stage0[i]),
                .b(rot2[i]),
                .sel(ctrl[1]),
                .y(stage1[i])
            );
        end
    endgenerate

    // Stage 2: select between stage1 and rot1 based on ctrl[0]
    generate
        for (i = 0; i < 8; i = i + 1) begin : stage2_gen
            mux2X1 u_mux_s2 (
                .a(stage1[i]),
                .b(rot1[i]),
                .sel(ctrl[0]),
                .y(out[i])
            );
        end
    endgenerate

endmodule