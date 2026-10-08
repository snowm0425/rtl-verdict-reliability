module multi_pipe_4bit (
    input clk,          // Clock signal
    input rst_n,        // Active-low reset signal
    input [3:0] mul_a,  // 4-bit multiplicand
    input [3:0] mul_b,  // 4-bit multiplier
    output [7:0] mul_out // 8-bit product output
);

    parameter size = 4;

    // Extended inputs with 'size' number of zero bits
    wire [7:0] extended_mul_a = { {size{1'b0}}, mul_a };
    wire [7:0] extended_mul_b = { {size{1'b0}}, mul_b };

    // Partial products
    wire [7:0] partial_products [0:size-1];

    // Intermediate sums
    reg [7:0] sum_reg1 [0:size-1];
    reg [7:0] sum_reg2 [0:size-1];

    // Final product
    reg [7:0] final_product;

    // Generate partial products
    genvar i;
    generate
        for (i = 0; i < size; i = i + 1) begin : gen_partial_products
            assign partial_products[i] = (extended_mul_b[i] == 1'b1) ? (extended_mul_a << i) : 8'b0;
        end
    endgenerate

    // Pipeline registers
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            // Reset all registers
            for (int j = 0; j < size; j = j + 1) begin
                sum_reg1[j] <= 8'b0;
                sum_reg2[j] <= 8'b0;
            end
            final_product <= 8'b0;
        end else begin
            // First stage of pipeline: sum partial products
            sum_reg1[0] <= partial_products[0];
            for (int j = 1; j < size; j = j + 1) begin
                sum_reg1[j] <= sum_reg1[j-1] + partial_products[j];
            end

            // Second stage of pipeline: sum results from first stage
            sum_reg2[0] <= sum_reg1[size-1];
            for (int j = 1; j < size; j = j + 1) begin
                sum_reg2[j] <= sum_reg2[j-1] + sum_reg1[j];
            end

            // Final product
            final_product <= sum_reg2[size-1];
        end
    end

    // Assign final product to output
    assign mul_out = final_product;

endmodule