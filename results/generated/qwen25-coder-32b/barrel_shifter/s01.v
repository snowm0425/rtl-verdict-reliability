module barrel_shifter(
    input [7:0] in,     // 8-bit input to be shifted
    input [2:0] ctrl,   // 3-bit control signal
    output [7:0] out    // 8-bit shifted output
);
    wire [7:0] shift1, shift2, shift4;

    // Shift by 4 positions
    assign shift4 = {in[3:0], in[7:4]};

    // Shift by 2 positions
    assign shift2 = {in[6:0], in[7]};

    // Shift by 1 position
    assign shift1 = {in[7:1], in[0]};

    wire [7:0] m4_out, m2_out, m1_out;

    // Mux to select between original input and shifted by 4
    mux2X1 m4(
        .sel(ctrl[2]),
        .in0(in),
        .in1(shift4),
        .out(m4_out)
    );

    // Mux to select between previous result and shifted by 2
    mux2X1 m2(
        .sel(ctrl[1]),
        .in0(m4_out),
        .in1(shift2),
        .out(m2_out)
    );

    // Mux to select between previous result and shifted by 1
    mux2X1 m1(
        .sel(ctrl[0]),
        .in0(m2_out),
        .in1(shift1),
        .out(m1_out)
    );

    // Final output
    assign out = m1_out;
endmodule