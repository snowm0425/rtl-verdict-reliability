module adder_pipe_64bit (
    input wire clk,
    input wire rst_n,
    input wire i_en,
    input wire [63:0] adda,
    input wire [63:0] addb,
    output reg [64:0] result,
    output reg o_en
);

    // Internal signals for pipeline stages
    reg [15:0] adda_stage1, addb_stage1, adda_stage2, addb_stage2, adda_stage3, addb_stage3;
    reg [15:0] sum_stage1, sum_stage2, sum_stage3;
    reg [16:0] sum_stage0;
    reg [1:0] carry_stage1, carry_stage2, carry_stage3;
    reg [65:0] sum_final;

    // Pipeline registers
    reg i_en_stage1, i_en_stage2, i_en_stage3, i_en_stage4;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            i_en_stage1 <= 0;
            i_en_stage2 <= 0;
            i_en_stage3 <= 0;
            i_en_stage4 <= 0;
            o_en <= 0;
            result <= 0;
        end else begin
            // Shift enable signal through pipeline stages
            i_en_stage1 <= i_en;
            i_en_stage2 <= i_en_stage1;
            i_en_stage3 <= i_en_stage2;
            i_en_stage4 <= i_en_stage3;
            o_en <= i_en_stage4;

            // Shift operands through pipeline stages
            adda_stage1 <= adda[15:0];
            adda_stage2 <= adda[31:16];
            adda_stage3 <= adda[47:32];
            sum_stage0[15:0] <= adda[63:48];

            addb_stage1 <= addb[15:0];
            addb_stage2 <= addb[31:16];
            addb_stage3 <= addb[47:32];
            sum_stage0[31:16] <= addb[63:48];

            // Calculate sums and carries for each stage
            {carry_stage1[0], sum_stage1} = adda_stage1 + addb_stage1;
            {carry_stage1[1], sum_stage2} = adda_stage2 + addb_stage2 + carry_stage1[0];
            {carry_stage2[0], sum_stage3} = adda_stage3 + addb_stage3 + carry_stage1[1];
            {carry_stage2[1], sum_final[15:0]} = sum_stage0 + carry_stage2[0];

            // Final sum calculation
            sum_final[31:16] = sum_stage1 + carry_stage2[1];
            sum_final[47:32] = sum_stage2;
            sum_final[63:48] = sum_stage3;

            // Final output
            result <= sum_final;
        end
    end

endmodule