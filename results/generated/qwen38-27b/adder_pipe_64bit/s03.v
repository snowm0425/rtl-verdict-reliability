module adder_pipe_64bit (
    input        clk,
    input        rst_n,
    input        i_en,
    input  [63:0] adda,
    input  [63:0] addb,
    output reg [64:0] result,
    output reg       o_en
);

    // Pipeline registers for operand A
    reg [63:0] a_stage1;
    reg [63:0] a_stage2;
    reg [63:0] a_stage3;
    reg [63:0] a_stage4;

    // Pipeline registers for operand B
    reg [63:0] b_stage1;
    reg [63:0] b_stage2;
    reg [63:0] b_stage3;
    reg [63:0] b_stage4;

    // Pipeline registers for carry
    reg        carry_stage1;
    reg        carry_stage2;
    reg        carry_stage3;
    reg        carry_stage4;

    // Pipeline registers for enable
    reg        en_stage1;
    reg        en_stage2;
    reg        en_stage3;
    reg        en_stage4;

    // Intermediate sum results for each stage
    wire [64:0] sum_stage1;
    wire [64:0] sum_stage2;
    wire [64:0] sum_stage3;
    wire [64:0] sum_stage4;

    // Stage 1: Add lower 16 bits
    assign sum_stage1 = a_stage1[15:0] + b_stage1[15:0] + carry_stage1;

    // Stage 2: Add next 16 bits with carry from stage 1
    assign sum_stage2 = a_stage2[31:16] + b_stage2[31:16] + sum_stage1[16];

    // Stage 3: Add next 16 bits with carry from stage 2
    assign sum_stage3 = a_stage3[47:32] + b_stage3[47:32] + sum_stage2[16];

    // Stage 4: Add upper 16 bits with carry from stage 3
    assign sum_stage4 = a_stage4[63:48] + b_stage4[63:48] + sum_stage3[16];

    // Register the pipeline stages
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            a_stage1 <= 64'd0;
            a_stage2 <= 64'd0;
            a_stage3 <= 64'd0;
            a_stage4 <= 64'd0;
            b_stage1 <= 64'd0;
            b_stage2 <= 64'd0;
            b_stage3 <= 64'd0;
            b_stage4 <= 64'd0;
            carry_stage1 <= 1'b0;
            carry_stage2 <= 1'b0;
            carry_stage3 <= 1'b0;
            carry_stage4 <= 1'b0;
            en_stage1 <= 1'b0;
            en_stage2 <= 1'b0;
            en_stage3 <= 1'b0;
            en_stage4 <= 1'b0;
            result <= 65'd0;
            o_en <= 1'b0;
        end else begin
            // Stage 1: Capture inputs if enabled
            if (i_en) begin
                a_stage1 <= adda;
                b_stage1 <= addb;
                carry_stage1 <= 1'b0;
                en_stage1 <= 1'b1;
            end else begin
                a_stage1 <= 64'd0;
                b_stage1 <= 64'd0;
                carry_stage1 <= 1'b0;
                en_stage1 <= 1'b0;
            end

            // Stage 2
            a_stage2 <= a_stage1;
            b_stage2 <= b_stage1;
            carry_stage2 <= sum_stage1[16];
            en_stage2 <= en_stage1;

            // Stage 3
            a_stage3 <= a_stage2;
            b_stage3 <= b_stage2;
            carry_stage3 <= sum_stage2[16];
            en_stage3 <= en_stage2;

            // Stage 4
            a_stage4 <= a_stage3;
            b_stage4 <= b_stage3;
            carry_stage4 <= sum_stage3[16];
            en_stage4 <= en_stage3;

            // Output stage
            if (en_stage4) begin
                result <= {sum_stage4[16], sum_stage3[15:0], sum_stage2[15:0], sum_stage1[15:0]};
                o_en <= 1'b1;
            end else begin
                result <= 65'd0;
                o_en <= 1'b0;
            end
        end
    end

endmodule