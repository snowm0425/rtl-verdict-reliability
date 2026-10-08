module barrel_shifter (
    input [7:0] in,
    input [2:0] ctrl,
    output [7:0] out
);
    // Intermediate signals for each stage of the barrel shifter
    wire [7:0] shift4;
    wire [7:0] shift4_2;
    wire [7:0] shift4_2_1;

    // Shift by 4 positions
    assign shift4 = {in[3:0], in[7:4]}; // Logical right shift by 4 positions

    // First mux to select between original input and shifted by 4 positions
    mux2X1 mux1 (
        .in0(in),
        .in1(shift4),
        .sel(ctrl[2]),
        .out(shift4_2)
    );

    // Shift by 2 positions
    assign shift4_2[7:0] = {shift4_2[5:0], shift4_2[7:6]}; // Logical right shift by 2 positions

    // Second mux to select between previous result and shifted by 2 positions
    mux2X1 mux2 (
        .in0(shift4_2),
        .in1(shift4_2[7:0] << 2), // Logical left shift by 2 positions
        .sel(ctrl[1]),
        .out(shift4_2_1)
    );

    // Shift by 1 position
    assign shift4_2_1[7:0] = {shift4_2_1[6:0], shift4_2_1[7]}; // Logical right shift by 1 position

    // Third mux to select between previous result and shifted by 1 position
    mux2X1 mux3 (
        .in0(shift4_2_1),
        .in1(shift4_2_1 << 1), // Logical left shift by 1 position
        .sel(ctrl[0]),
        .out(out)
    );
endmodule