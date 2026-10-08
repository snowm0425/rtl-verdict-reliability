module mux2X1 (
    input wire sel,          // Select signal
    input wire [7:0] in0,    // First input
    input wire [7:0] in1,    // Second input
    output wire [7:0] out    // Output
);
    assign out = sel ? in1 : in0;
endmodule

// barrel_shifter module
module barrel_shifter (
    input wire [7:0] in,    // 8-bit input
    input wire [2:0] ctrl,  // 3-bit control signal
    output wire [7:0] out   // 8-bit output
);
    wire [7:0] shift_4;     // Intermediate result after 4-bit shift
    wire [7:0] shift_2;     // Intermediate result after 2-bit shift
    wire [7:0] shift_1;     // Intermediate result after 1-bit shift

    // Shift by 4 positions
    mux2X1 mux4 (
        .sel(ctrl[2]),
        .in0(in),
        .in1({in[3:0], in[7:4]}),
        .out(shift_4)
    );

    // Shift by 2 positions
    mux2X1 mux2 (
        .sel(ctrl[1]),
        .in0(shift_4),
        .in1({shift_4[5:0], shift_4[7:6]}),
        .out(shift_2)
    );

    // Shift by 1 position
    mux2X1 mux1 (
        .sel(ctrl[0]),
        .in0(shift_2),
        .in1({shift_2[6:0], shift_2[7]}),
        .out(shift_1)
    );

    // Final output
    assign out = shift_1;
endmodule