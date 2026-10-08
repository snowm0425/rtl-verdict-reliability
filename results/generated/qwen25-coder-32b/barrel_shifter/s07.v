module barrel_shifter (
    input [7:0] in,   // 8-bit input to be shifted
    input [2:0] ctrl, // 3-bit control signal
    output [7:0] out  // 8-bit shifted output
);

// Intermediate signals for each stage of shifting
wire [7:0] shift_4;  // Result after shifting by 4 positions
wire [7:0] shift_2;  // Result after shifting by 2 positions
wire [7:0] shift_1;  // Result after shifting by 1 position

// Stage 1: Shift by 4 positions if ctrl[2] is high
mux2X1 mux4 (
    .in0(in), 
    .in1({in[3:0], in[7:4]}), 
    .sel(ctrl[2]), 
    .out(shift_4)
);

// Stage 2: Shift by 2 positions if ctrl[1] is high
mux2X1 mux2 (
    .in0(shift_4), 
    .in1({shift_4[5:0], shift_4[7:6]}), 
    .sel(ctrl[1]), 
    .out(shift_2)
);

// Stage 3: Shift by 1 position if ctrl[0] is high
mux2X1 mux1 (
    .in0(shift_2), 
    .in1({shift_2[6:0], shift_2[7]}), 
    .sel(ctrl[0]), 
    .out(shift_1)
);

// Final output is the result after all shifts
assign out = shift_1;

endmodule