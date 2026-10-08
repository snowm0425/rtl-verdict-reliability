module adder_pipe_64bit (
    input        clk,
    input        rst_n,
    input        i_en,
    input  [63:0] adda,
    input  [63:0] addb,
    output [64:0] result,
    output       o_en
);

    // Pipeline registers
    // Stage 0: capture inputs and enable
    reg [63:0] stage0_a;
    reg [63:0] stage0_b;
    reg        stage0_en;

    // Stage 1: compute partial sum and carry for lower 32 bits
    // We can break the 64-bit addition into two 32-bit additions with carry propagation
    // Let's do a 2-stage pipeline:
    // Stage 1: compute lower 32-bit sum and carry out
    // Stage 2: compute upper 32-bit sum using carry from stage 1, combine to form final 65-bit result

    // Stage 1 registers
    reg [31:0] stage1_low_sum;
    reg        stage1_carry;
    reg [31:0] stage1_high_a;
    reg [31:0] stage1_high_b;
    reg        stage1_en;

    // Stage 2 registers (final result and output enable)
    reg [64:0] stage2_result;
    reg        stage2_en;

    // Stage 0: capture inputs on i_en
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            stage0_a  <= 64'd0;
            stage0_b  <= 64'd0;
            stage0_en <= 1'b0;
        end else begin
            stage0_a  <= adda;
            stage0_b  <= addb;
            stage0_en <= i_en;
        end
    end

    // Stage 1: compute lower 32-bit addition
    // low 32 bits of a and b
    wire [31:0] low_a  = stage0_a[31:0];
    wire [31:0] low_b  = stage0_b[31:0];
    wire [31:0] high_a = stage0_a[63:32];
    wire [31:0] high_b = stage0_b[63:32];

    // Add lower 32 bits, get sum[31:0] and carry out
    wire [32:0] low_add = {1'b0, low_a} + {1'b0, low_b};
    wire [31:0] low_sum = low_add[31:0];
    wire        low_carry = low_add[32];

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            stage1_low_sum  <= 32'd0;
            stage1_carry    <= 1'b0;
            stage1_high_a   <= 32'd0;
            stage1_high_b   <= 32'd0;
            stage1_en       <= 1'b0;
        end else begin
            stage1_low_sum  <= low_sum;
            stage1_carry    <= low_carry;
            stage1_high_a   <= high_a;
            stage1_high_b   <= high_b;
            stage1_en       <= stage0_en;
        end
    end

    // Stage 2: compute upper 32-bit addition with carry in
    wire [32:0] high_add = {1'b0, stage1_high_a} + {1'b0, stage1_high_b} + {32'd0, stage1_carry};
    wire [31:0] high_sum = high_add[31:0];
    wire        high_carry = high_add[32];

    // Combine to form 65-bit result: {high_carry, high_sum, low_sum}
    wire [64:0] combined_result = {high_carry, high_sum, stage1_low_sum};

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            stage2_result <= 65'd0;
            stage2_en     <= 1'b0;
        end else begin
            stage2_result <= combined_result;
            stage2_en     <= stage1_en;
        end
    end

    // Output assignments
    assign result = stage2_result;
    assign o_en   = stage2_en;

endmodule