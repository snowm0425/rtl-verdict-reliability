module mux2X1(
    input a,
    input b,
    input sel,
    output y
);
    assign y = sel ? b : a;
endmodule

module barrel_shifter(
    input [7:0] in,
    input [2:0] ctrl,
    output [7:0] out
);
    wire [7:0] stage0, stage1, stage2;

    // Stage 0: shift by 1 if ctrl[0] is high
    genvar i;
    generate
        for (i = 0; i < 8; i = i + 1) begin : stage0_gen
            mux2X1 u_mux0 (
                .a(in[i]),
                .b(in[(i+1) % 8]),
                .sel(ctrl[0]),
                .y(stage0[i])
            );
        end
    endgenerate

    // Stage 1: shift by 2 if ctrl[1] is high
    generate
        for (i = 0; i < 8; i = i + 1) begin : stage1_gen
            mux2X1 u_mux1 (
                .a(stage0[i]),
                .b(stage0[(i+2) % 8]),
                .sel(ctrl[1]),
                .y(stage1[i])
            );
        end
    endgenerate

    // Stage 2: shift by 4 if ctrl[2] is high
    generate
        for (i = 0; i < 8; i = i + 1) begin : stage2_gen
            mux2X1 u_mux2 (
                .a(stage1[i]),
                .b(stage1[(i+4) % 8]),
                .sel(ctrl[2]),
                .y(out[i])
            );
        end
    endgenerate

endmodule