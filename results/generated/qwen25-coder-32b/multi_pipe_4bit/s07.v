module multi_pipe_4bit (
    input wire clk,          // Clock signal
    input wire rst_n,        // Active-low reset signal
    input wire [3:0] mul_a,  // 4-bit multiplicand
    input wire [3:0] mul_b,  // 4-bit multiplier
    output reg [7:0] mul_out // 8-bit product
);

    parameter size = 4;

    // Intermediate registers
    reg [7:0] partial_product [0:size-1];
    reg [7:0] sum_level1 [0:size-1];
    reg [7:0] sum_level2 [0:size-1];

    // Extend input signals
    wire [7:0] extended_mul_a = {4'b0000, mul_a};

    // Generate block for partial products
    generate
        genvar i;
        for (i = 0; i < size; i = i + 1) begin : gen_partial_products
            always @(posedge clk or negedge rst_n) begin
                if (!rst_n) begin
                    partial_product[i] <= 8'b00000000;
                end else begin
                    if (mul_b[i]) begin
                        partial_product[i] <= extended_mul_a << i;
                    end else begin
                        partial_product[i] <= 8'b00000000;
                    end
                end
            end
        end
    endgenerate

    // First level of sum
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            sum_level1 <= '{default: 8'b00000000};
        end else begin
            sum_level1[0] <= partial_product[0];
            for (int j = 1; j < size; j = j + 1) begin
                sum_level1[j] <= sum_level1[j-1] + partial_product[j];
            end
        end
    end

    // Second level of sum
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            sum_level2 <= '{default: 8'b00000000};
        end else begin
            sum_level2[0] <= sum_level1[0];
            for (int j = 1; j < size; j = j + 1) begin
                sum_level2[j] <= sum_level2[j-1] + sum_level1[j];
            end
        end
    end

    // Final product calculation
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            mul_out <= 8'b00000000;
        end else begin
            mul_out <= sum_level2[size-1];
        end
    end

endmodule