module multi_pipe_4bit (
    input wire clk,          // Clock signal used for synchronous operation
    input wire rst_n,        // Active-low reset signal
    input wire [3:0] mul_a,  // Input signal representing the multiplicand
    input wire [3:0] mul_b,  // Input signal representing the multiplier
    output reg [7:0] mul_out // Product output signal
);

    parameter size = 4;

    // Extended inputs
    wire [7:0] extended_mul_a = {4'b0000, mul_a}; // Extend multiplicand by 4 zeros
    wire [7:0] extended_mul_b = {4'b0000, mul_b}; // Extend multiplier by 4 zeros

    // Partial products
    wire [7:0] partial_product [0:size-1];

    // Intermediate sums
    reg [7:0] intermediate_sum_1;
    reg [7:0] intermediate_sum_2;

    // Generate partial products
    genvar i;
    generate
        for (i = 0; i < size; i = i + 1) begin : gen_partial_products
            assign partial_product[i] = (extended_mul_b[i]) ? (extended_mul_a << i) : 8'b00000000;
        end
    endgenerate

    // Register to store first level of intermediate sums
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            intermediate_sum_1 <= 8'b00000000;
        end else begin
            intermediate_sum_1 <= partial_product[0] + partial_product[1];
        end
    end

    // Register to store second level of intermediate sums
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            intermediate_sum_2 <= 8'b00000000;
        end else begin
            intermediate_sum_2 <= intermediate_sum_1 + partial_product[2] + partial_product[3];
        end
    end

    // Final product calculation
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            mul_out <= 8'b00000000;
        end else begin
            mul_out <= intermediate_sum_2;
        end
    end

endmodule