module adder_pipe_64bit (
    input wire clk,          // Clock input
    input wire rst_n,        // Active low reset signal
    input wire i_en,         // Enable signal for addition operation
    input wire [63:0] adda,  // 64-bit input operand A
    input wire [63:0] addb,  // 64-bit input operand B
    output reg [64:0] result, // 65-bit output representing the sum of adda and addb
    output reg o_en          // Output enable signal
);

    // Pipeline stage registers
    reg [63:0] adda_reg1, adda_reg2, adda_reg3, adda_reg4;
    reg [63:0] addb_reg1, addb_reg2, addb_reg3, addb_reg4;
    reg i_en_reg1, i_en_reg2, i_en_reg3, i_en_reg4;

    // Intermediate sum and carry signals
    wire [63:0] sum1, sum2, sum3, sum4;
    wire c1, c2, c3, c4;

    // First stage
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            adda_reg1 <= 0;
            addb_reg1 <= 0;
            i_en_reg1 <= 0;
        end else begin
            adda_reg1 <= adda;
            addb_reg1 <= addb;
            i_en_reg1 <= i_en;
        end
    end

    // Second stage
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            adda_reg2 <= 0;
            addb_reg2 <= 0;
            i_en_reg2 <= 0;
        end else begin
            adda_reg2 <= adda_reg1;
            addb_reg2 <= addb_reg1;
            i_en_reg2 <= i_en_reg1;
        end
    end

    // Third stage
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            adda_reg3 <= 0;
            addb_reg3 <= 0;
            i_en_reg3 <= 0;
        end else begin
            adda_reg3 <= adda_reg2;
            addb_reg3 <= addb_reg2;
            i_en_reg3 <= i_en_reg2;
        end
    end

    // Fourth stage
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            adda_reg4 <= 0;
            addb_reg4 <= 0;
            i_en_reg4 <= 0;
        end else begin
            adda_reg4 <= adda_reg3;
            addb_reg4 <= addb_reg3;
            i_en_reg4 <= i_en_reg3;
        end
    end

    // Ripple carry adder calculations
    assign {c1, sum1} = adda_reg1 + addb_reg1;
    assign {c2, sum2} = sum1 + c1;
    assign {c3, sum3} = sum2 + c2;
    assign {c4, sum4} = sum3 + c3;

    // Final result and output enable
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            result <= 0;
            o_en <= 0;
        end else if (i_en_reg4) begin
            result <= {c4, sum4};
            o_en <= 1;
        end else begin
            o_en <= 0;
        end
    end

endmodule