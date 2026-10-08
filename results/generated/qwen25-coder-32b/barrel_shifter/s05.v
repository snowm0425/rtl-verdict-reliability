module barrel_shifter (
    input  [7:0] in,   // 8-bit input
    input  [2:0] ctrl, // 3-bit control signal
    output [7:0] out   // 8-bit output
);
    wire [7:0] shift_4, shift_2, shift_1;

    // Shift by 4 positions
    assign shift_4 = {in[3:0], in[7:4]};

    // Shift by 2 positions
    assign shift_2 = {in[5:0], in[7:6]};

    // Shift by 1 position
    assign shift_1 = {in[6:0], in[7]};

    // Intermediate signals for multiplexer stages
    wire [7:0] stage_4, stage_2;

    // Stage 1: Shift by 4 positions if ctrl[2] is high
    mux2X1 mux4 (
        .in0(in),
        .in1(shift_4),
        .sel(ctrl[2]),
        .out(stage_4)
    );

    // Stage 2: Shift by 2 positions if ctrl[1] is high
    mux2X1 mux2 (
        .in0(stage_4),
        .in1({stage_4[5:0], stage_4[7:6]}),
        .sel(ctrl[1]),
        .out(stage_2)
    );

    // Stage 3: Shift by 1 position if ctrl[0] is high
    mux2X1 mux1 (
        .in0(stage_2),
        .in1({stage_2[6:0], stage_2[7]}),
        .sel(ctrl[0]),
        .out(out)
    );

endmodule