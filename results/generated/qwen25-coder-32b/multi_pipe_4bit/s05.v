module multi_pipe_4bit (
    input clk,          // Clock signal
    input rst_n,        // Active-low reset signal
    input [3:0] mul_a,  // 4-bit multiplicand
    input [3:0] mul_b,  // 4-bit multiplier
    output [7:0] mul_out // 8-bit product
);

    parameter size = 4;

    // Extended partial products
    reg [7:0] partial_products [0:size-1];

    // Intermediate sum registers
    reg [7:0] sum_reg1;
    reg [7:0] sum_reg2;

    // Final product
    reg [7:0] product;

    // Generate block to calculate partial products
    generate
        genvar i;
        for (i = 0; i < size; i = i + 1) begin : gen_partial_products
            always @(posedge clk or negedge rst_n) begin
                if (!rst_n) begin
                    partial_products[i] <= 8'b0;
                end else begin
                    if (mul_b[i])
                        partial_products[i] <= {mul_a, 4'b0} << i;
                    else
                        partial_products[i] <= 8'b0;
                end
            end
        end
    endgenerate

    // First level of adder
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            sum_reg1 <= 8'b0;
        end else begin
            sum_reg1 <= partial_products[0] + partial_products[1];
        end
    end

    // Second level of adder
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            sum_reg2 <= 8'b0;
        end else begin
            sum_reg2 <= sum_reg1 + partial_products[2] + partial_products[3];
        end
    end

    // Final product calculation
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            product <= 8'b0;
        end else begin
            product <= sum_reg2;
        end
    end

    // Assign final product to output
    assign mul_out = product;

endmodule