module
module mux2X1 (
    input  sel,
    input  [7:0] in0,
    input  [7:0] in1,
    output [7:0] out
);
    assign out = sel ? in1 : in0;
endmodule

// barrel_shifter module
module barrel_shifter (
    input  [7:0] in,
    input  [2:0] ctrl,
    output [7:0] out
);
    // Intermediate signals for each stage of shifting
    wire [7:0] stage1_out;
    wire [7:0] stage2_out;
    wire [7:0] stage3_out;

    // Stage 1: Shift by 4 positions if ctrl[2] is high
    wire [7:0] shifted_by_4 = {in[3:0], in[7:4]};
    mux2X1 mux_stage1 (
        .sel(ctrl[2]),
        .in0(in),
        .in1(shifted_by_4),
        .out(stage1_out)
    );

    // Stage 2: Shift by 2 positions if ctrl[1] is high
    wire [7:0] shifted_by_2 = {stage1_out[1:0], stage1_out[7:2]};
    mux2X1 mux_stage2 (
        .sel(ctrl[1]),
        .in0(stage1_out),
        .in1(shifted_by_2),
        .out(stage2_out)
    );

    // Stage 3: Shift by 1 position if ctrl[0] is high
    wire [7:0] shifted_by_1 = {stage2_out[0], stage2_out[7:1]};
    mux2X1 mux_stage3 (
        .sel(ctrl[0]),
        .in0(stage2_out),
        .in1(shifted_by_1),
        .out(stage3_out)
    );

    // Final output
    assign out = stage3_out;
endmodule