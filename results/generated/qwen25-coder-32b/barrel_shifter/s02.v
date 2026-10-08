module barrel_shifter (
    input [7:0] in,
    input [2:0] ctrl,
    output [7:0] out
);
    // Intermediate signals for the barrel shifter stages
    wire [7:0] stage1;
    wire [7:0] stage2;
    wire [7:0] stage3;

    // Stage 1: Shift by 4 positions if ctrl[2] is high
    assign stage1 = ctrl[2] ? {in[3:0], in[7:4]} : in;

    // Stage 2: Shift by 2 positions if ctrl[1] is high
    mux2X1 mux_stage2 (
        .sel(ctrl[1]),
        .in0(stage1),
        .in1({stage1[5:0], stage1[7:6]}),
        .out(stage2)
    );

    // Stage 3: Shift by 1 position if ctrl[0] is high
    mux2X1 mux_stage3 (
        .sel(ctrl[0]),
        .in0(stage2),
        .in1({stage2[6:0], stage2[7]}),
        .out(stage3)
    );

    // Final output
    assign out = stage3;
endmodule