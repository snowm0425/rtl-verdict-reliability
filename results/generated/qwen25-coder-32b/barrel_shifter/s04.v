module barrel_shifter (
    input [7:0] in,  // 8-bit input to be shifted
    input [2:0] ctrl, // 3-bit control signal
    output reg [7:0] out // 8-bit shifted output
);

// Intermediate signals for each stage
wire [7:0] stage1;
wire [7:0] stage2;
wire [7:0] stage3;

// Stage 1: Shift by 4 positions
generate
    genvar i;
    for (i = 0; i < 8; i = i + 1) begin : gen_stage1
        mux2X1 mux1 (
            .sel(ctrl[2]),
            .a(in[i]),
            .b(in[i-4]), // Shift left by 4 positions
            .y(stage1[i])
        );
    end
endgenerate

// Stage 2: Shift by 2 positions
generate
    for (i = 0; i < 8; i = i + 1) begin : gen_stage2
        mux2X1 mux2 (
            .sel(ctrl[1]),
            .a(stage1[i]),
            .b(stage1[i-2]), // Shift left by 2 positions
            .y(stage2[i])
        );
    end
endgenerate

// Stage 3: Shift by 1 position
generate
    for (i = 0; i < 8; i = i + 1) begin : gen_stage3
        mux2X1 mux3 (
            .sel(ctrl[0]),
            .a(stage2[i]),
            .b(stage2[i-1]), // Shift left by 1 position
            .y(stage3[i])
        );
    end
endgenerate

// Assign the final output
assign out = stage3;

endmodule