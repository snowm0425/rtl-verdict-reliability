module multi_pipe_4bit (
    input clk,          // Clock signal
    input rst_n,        // Active-low reset signal
    input [3:0] mul_a,  // 4-bit multiplicand
    input [3:0] mul_b,  // 4-bit multiplier
    output [7:0] mul_out // 8-bit product
);

    parameter size = 4;

    // Extended inputs
    wire [7:0] ext_mul_a = {4'b0000, mul_a};
    wire [7:0] ext_mul_b = {4'b0000, mul_b};

    // Partial products
    wire [7:0] partial_prod [0:size-1];

    // Registers for intermediate sums
    reg [7:0] reg_sum1;
    reg [7:0] reg_sum2;

    // Generate partial products
    genvar i;
    generate
        for (i = 0; i < size; i = i + 1) begin : gen_partial_prod
            assign partial_prod[i] = (ext_mul_b[i]) ? (ext_mul_a << i) : 8'b0;
        end
    endgenerate

    // Register for storing intermediate sums
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            reg_sum1 <= 8'b0;
            reg_sum2 <= 8'b0;
        end else begin
            reg_sum1 <= partial_prod[0] + partial_prod[1];
            reg_sum2 <= reg_sum1 + partial_prod[2] + partial_prod[3];
        end
    end

    // Final product calculation
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            mul_out <= 8'b0;
        end else begin
            mul_out <= reg_sum2;
        end
    end

endmodule