module multi_pipe_4bit (
    input clk,          // Clock signal
    input rst_n,        // Active-low reset signal
    input [3:0] mul_a,  // 4-bit multiplicand
    input [3:0] mul_b,  // 4-bit multiplier
    output reg [7:0] mul_out // 8-bit product
);

    parameter size = 4;

    // Intermediate registers
    reg [7:0] partial_product [0:size-1]; // Partial products
    reg [7:0] sum_reg_1;                  // First level sum register
    reg [7:0] sum_reg_2;                  // Second level sum register

    // Extend inputs to 8 bits
    wire [7:0] extended_mul_a = {4'b0000, mul_a};

    // Generate partial products
    genvar i;
    generate
        for (i = 0; i < size; i = i + 1) begin : gen_partial_products
            assign partial_product[i] = (mul_b[i]) ? (extended_mul_a << i) : 8'b0;
        end
    endgenerate

    // First level sum register
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            sum_reg_1 <= 8'b0;
        end else begin
            sum_reg_1 <= partial_product[0] + partial_product[1];
        end
    end

    // Second level sum register
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            sum_reg_2 <= 8'b0;
        end else begin
            sum_reg_2 <= sum_reg_1 + partial_product[2] + partial_product[3];
        end
    end

    // Final product output register
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            mul_out <= 8'b0;
        end else begin
            mul_out <= sum_reg_2;
        end
    end

endmodule