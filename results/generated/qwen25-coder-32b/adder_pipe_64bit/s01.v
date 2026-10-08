module adder_pipe_64bit (
    input clk,          // Clock input
    input rst_n,        // Active low reset signal
    input i_en,         // Enable signal for addition operation
    input [63:0] adda,  // 64-bit input operand A
    input [63:0] addb,  // 64-bit input operand B
    output [64:0] result, // 65-bit output representing the sum of adda and addb
    output o_en         // Output enable signal
);

    // Internal signals for pipeline stages
    reg [63:0] adda_reg1, adda_reg2, adda_reg3, adda_reg4;
    reg [63:0] addb_reg1, addb_reg2, addb_reg3, addb_reg4;
    reg i_en_reg1, i_en_reg2, i_en_reg3, i_en_reg4;
    reg [64:0] sum_stage1, sum_stage2, sum_stage3, sum_stage4;

    // Pipeline stage 1
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            adda_reg1 <= 64'b0;
            addb_reg1 <= 64'b0;
            i_en_reg1 <= 1'b0;
        end else begin
            adda_reg1 <= adda;
            addb_reg1 <= addb;
            i_en_reg1 <= i_en;
        end
    end

    // Pipeline stage 2
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            adda_reg2 <= 64'b0;
            addb_reg2 <= 64'b0;
            i_en_reg2 <= 1'b0;
            sum_stage1 <= 65'b0;
        end else begin
            adda_reg2 <= adda_reg1;
            addb_reg2 <= addb_reg1;
            i_en_reg2 <= i_en_reg1;
            sum_stage1 <= {1'b0, adda_reg1} + {1'b0, addb_reg1}; // Calculate sum for first 32 bits
        end
    end

    // Pipeline stage 3
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            adda_reg3 <= 64'b0;
            addb_reg3 <= 64'b0;
            i_en_reg3 <= 1'b0;
            sum_stage2 <= 65'b0;
        end else begin
            adda_reg3 <= adda_reg2;
            addb_reg3 <= addb_reg2;
            i_en_reg3 <= i_en_reg2;
            sum_stage2 <= {sum_stage1[32], adda_reg2[32:0]} + {sum_stage1[32], addb_reg2[32:0]} + sum_stage1[33]; // Calculate sum for second 32 bits
        end
    end

    // Pipeline stage 4
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            adda_reg4 <= 64'b0;
            addb_reg4 <= 64'b0;
            i_en_reg4 <= 1'b0;
            sum_stage3 <= 65'b0;
            sum_stage4 <= 65'b0;
            o_en <= 1'b0;
            result <= 65'b0;
        end else begin
            adda_reg4 <= adda_reg3;
            addb_reg4 <= addb_reg3;
            i_en_reg4 <= i_en_reg3;
            sum_stage3 <= {sum_stage2[32], adda_reg3[32:0]} + {sum_stage2[32], addb_reg3[32:0]} + sum_stage2[33]; // Calculate sum for second 32 bits
            sum_stage4 <= sum_stage3; // Final sum
            o_en <= i_en_reg4;
            result <= sum_stage4;
        end
    end

endmodule