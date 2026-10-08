module multi_pipe_4bit (
    input clk,          // Clock signal
    input rst_n,        // Active-low reset signal
    input [3:0] mul_a,  // 4-bit multiplicand
    input [3:0] mul_b,  // 4-bit multiplier
    output [7:0] mul_out // 8-bit product
);

    parameter size = 4;

    // Extended input signals
    wire [7:0] extended_mul_a = {4'b0000, mul_a};
    wire [7:0] extended_mul_b = {4'b0000, mul_b};

    // Partial products
    wire [7:0] partial_product [0:size-1];

    // Intermediate sum registers
    reg [7:0] sum_reg1 [0:size-1];
    reg [7:0] sum_reg2 [0:size-1];

    // Final product register
    reg [7:0] final_product;

    // Generate block for partial products
    genvar i;
    generate
        for (i = 0; i < size; i = i + 1) begin : gen_partial_products
            assign partial_product[i] = (extended_mul_b[i]) ? (extended_mul_a << i) : 8'b00000000;
        end
    endgenerate

    // First level of adders and registers
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            for (int j = 0; j < size; j = j + 1) begin
                sum_reg1[j] <= 8'b00000000;
            end
        end else begin
            sum_reg1[0] <= partial_product[0];
            for (int j = 1; j < size; j = j + 1) begin
                sum_reg1[j] <= sum_reg1[j-1] + partial_product[j];
            end
        end
    end

    // Second level of adders and registers
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            for (int j = 0; j < size; j = j + 1) begin
                sum_reg2[j] <= 8'b00000000;
            end
        end else begin
            sum_reg2[0] <= sum_reg1[0];
            for (int j = 1; j < size; j = j + 1) begin
                sum_reg2[j] <= sum_reg2[j-1] + sum_reg1[j];
            end
        end
    end

    // Final product calculation
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            final_product <= 8'b00000000;
        end else begin
            final_product <= sum_reg2[size-1];
        end
    end

    // Output assignment
    assign mul_out = final_product;

endmodule