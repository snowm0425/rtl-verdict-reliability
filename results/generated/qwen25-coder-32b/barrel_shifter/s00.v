module barrel_shifter (
    input  [7:0] in,     // 8-bit input to be shifted
    input  [2:0] ctrl,   // 3-bit control signal
    output [7:0] out     // 8-bit shifted output
);
    wire [7:0] shift4, shift4_res, shift2, shift2_res, shift1;

    // Shift by 4 positions
    assign shift4 = {in[3:0], in[7:4]};  // Logical right shift by 4

    // Mux to select between original input and shifted by 4
    mux2X1 mux4 (
        .sel(ctrl[2]),
        .in0(in),
        .in1(shift4),
        .out(shift4_res)
    );

    // Shift by 2 positions (from the previous result)
    assign shift2 = {shift4_res[1:0], shift4_res[7:2]};  // Logical right shift by 2

    // Mux to select between previous result and shifted by 2
    mux2X1 mux2 (
        .sel(ctrl[1]),
        .in0(shift4_res),
        .in1(shift2),
        .out(shift2_res)
    );

    // Shift by 1 position (from the previous result)
    assign shift1 = {shift2_res[0], shift2_res[7:1]};  // Logical right shift by 1

    // Mux to select between previous result and shifted by 1
    mux2X1 mux1 (
        .sel(ctrl[0]),
        .in0(shift2_res),
        .in1(shift1),
        .out(out)
    );

endmodule