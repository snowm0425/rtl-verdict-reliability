module adder_pipe_64bit (
    input        clk,
    input        rst_n,
    input        i_en,
    input  [63:0] adda,
    input  [63:0] addb,
    output [64:0] result,
    output       o_en
);

    // -----------------------------------------------------------------------
    // Pipeline Stages
    // We use 4 stages, each handling 16 bits.
    // 
    // Stage 0: Register input operands
    // Stage 1: Compute sum[15:0] and carry_out[16]
    // Stage 2: Compute sum[31:16] and carry_out[32]
    // Stage 3: Compute sum[47:32] and carry_out[48]
    // Stage 4: Compute sum[63:48] and carry_out[64]
    //
    // The enable signal is pipelined along with the data.
    // -----------------------------------------------------------------------

    // Pipeline register declarations
    // Stage 0: Input register
    reg [63:0] pipe_a0;
    reg [63:0] pipe_b0;
    reg        pipe_en0;

    // Stage 1: After processing bits [15:0]
    reg [15:0] pipe_sum1;
    reg        pipe_carry1;
    reg [47:0] pipe_a1; // Upper 48 bits of A
    reg [47:0] pipe_b1; // Upper 48 bits of B
    reg        pipe_en1;

    // Stage 2: After processing bits [31:16]
    reg [15:0] pipe_sum2;
    reg        pipe_carry2;
    reg [31:0] pipe_a2; // Upper 32 bits of A
    reg [31:0] pipe_b2; // Upper 32 bits of B
    reg        pipe_en2;

    // Stage 3: After processing bits [47:32]
    reg [15:0] pipe_sum3;
    reg        pipe_carry3;
    reg [15:0] pipe_a3; // Upper 16 bits of A
    reg [15:0] pipe_b3; // Upper 16 bits of B
    reg        pipe_en3;

    // Stage 4: Final result register
    reg [15:0] pipe_sum4;
    reg        pipe_carry4; // This is the MSB of the 65-bit result
    reg        pipe_en4;

    // -----------------------------------------------------------------------
    // Combinational Logic for Each Stage
    // -----------------------------------------------------------------------

    // --- Stage 1: Bits [15:0] ---
    // Add the lower 16 bits of A and B, with carry-in = 0
    wire [16:0] stage1_sum_carry;
    assign stage1_sum_carry = {pipe_a0[15:0], 1'b0} + {pipe_b0[15:0], 1'b0};
    // stage1_sum_carry[16] is the carry-out, stage1_sum_carry[15:0] is the sum

    // --- Stage 2: Bits [31:16] ---
    // Add the next 16 bits of A and B, with carry-in from Stage 1
    wire [16:0] stage2_sum_carry;
    assign stage2_sum_carry = {pipe_a1[15:0], pipe_carry1} + {pipe_b1[15:0], 1'b0};

    // --- Stage 3: Bits [47:32] ---
    // Add the next 16 bits of A and B, with carry-in from Stage 2
    wire [16:0] stage3_sum_carry;
    assign stage3_sum_carry = {pipe_a2[15:0], pipe_carry2} + {pipe_b2[15:0], 1'b0};

    // --- Stage 4: Bits [63:48] ---
    // Add the upper 16 bits of A and B, with carry-in from Stage 3
    wire [16:0] stage4_sum_carry;
    assign stage4_sum_carry = {pipe_a3[15:0], pipe_carry3} + {pipe_b3[15:0], 1'b0};

    // -----------------------------------------------------------------------
    // Sequential Logic (Pipeline Registers)
    // -----------------------------------------------------------------------

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            // Reset all pipeline registers
            pipe_a0    <= 64'd0;
            pipe_b0    <= 64'd0;
            pipe_en0   <= 1'b0;

            pipe_sum1  <= 16'd0;
            pipe_carry1<= 1'b0;
            pipe_a1    <= 48'd0;
            pipe_b1    <= 48'd0;
            pipe_en1   <= 1'b0;

            pipe_sum2  <= 16'd0;
            pipe_carry2<= 1'b0;
            pipe_a2    <= 32'd0;
            pipe_b2    <= 32'd0;
            pipe_en2   <= 1'b0;

            pipe_sum3  <= 16'd0;
            pipe_carry3<= 1'b0;
            pipe_a3    <= 16'd0;
            pipe_b3    <= 16'd0;
            pipe_en3   <= 1'b0;

            pipe_sum4  <= 16'd0;
            pipe_carry4<= 1'b0;
            pipe_en4   <= 1'b0;
        end else begin
            // --- Stage 0: Register inputs ---
            pipe_a0    <= adda;
            pipe_b0    <= addb;
            pipe_en0   <= i_en;

            // --- Stage 1: Register results of bits [15:0] ---
            pipe_sum1  <= stage1_sum_carry[15:0];
            pipe_carry1<= stage1_sum_carry[16];
            pipe_a1    <= pipe_a0[63:16]; // Pass upper 48 bits
            pipe_b1    <= pipe_b0[63:16];
            pipe_en1   <= pipe_en0;

            // --- Stage 2: Register results of bits [31:16] ---
            pipe_sum2  <= stage2_sum_carry[15:0];
            pipe_carry2<= stage2_sum_carry[16];
            pipe_a2    <= pipe_a1[31:0];  // Pass upper 32 bits
            pipe_b2    <= pipe_b1[31:0];
            pipe_en2   <= pipe_en1;

            // --- Stage 3: Register results of bits [47:32] ---
            pipe_sum3  <= stage3_sum_carry[15:0];
            pipe_carry3<= stage3_sum_carry[16];
            pipe_a3    <= pipe_a2[15:0];  // Pass upper 16 bits
            pipe_b3    <= pipe_b2[15:0];
            pipe_en3   <= pipe_en2;

            // --- Stage 4: Register final results of bits [63:48] ---
            pipe_sum4  <= stage4_sum_carry[15:0];
            pipe_carry4<= stage4_sum_carry[16];
            pipe_en4   <= pipe_en3;
        end
    end

    // -----------------------------------------------------------------------
    // Output Assignment
    // -----------------------------------------------------------------------

    // Assemble the 65-bit result from the pipeline stages
    // Bit 64 is the final carry-out
    // Bits [63:48] are from Stage 4
    // Bits [47:32] are from Stage 3
    // Bits [31:16] are from Stage 2
    // Bits [15:0] are from Stage 1
    assign result = {pipe_carry4, pipe_sum4, pipe_sum3, pipe_sum2, pipe_sum1};

    // Output enable is high when the result is valid
    assign o_en = pipe_en4;

endmodule