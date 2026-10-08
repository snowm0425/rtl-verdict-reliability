module multi_pipe_4bit (
    input clk,          // Clock signal
    input rst_n,        // Active-low reset signal
    input [3:0] mul_a,  // 4-bit multiplicand
    input [3:0] mul_b,  // 4-bit multiplier
    output [7:0] mul_out // 8-bit product output
);

    parameter size = 4;

    // Extended input signals
    wire [7:0] extended_mul_a = {4'b0000, mul_a};
    wire [7:0] extended_mul_b = {4'b0000, mul_b};

    // Partial products
    wire [7:0] partial_products [0:size-1];

    // Intermediate sums
    reg [7:0] reg1 [0:size-1];
    reg [7:0] reg2 [0:size-1];

    // Generate block for calculating partial products
    genvar i;
    generate
        for (i = 0; i < size; i = i + 1) begin : gen_partial_products
            assign partial_products[i] = extended_mul_b[i] ? (extended_mul_a << i) : 8'b0;
        end
    endgenerate

    // Register 1: Store partial products
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            for (int j = 0; j < size; j = j + 1) begin
                reg1[j] <= 8'b0;
            end
        end else begin
            for (int j = 0; j < size; j = j + 1) begin
                reg1[j] <= partial_products[j];
            end
        end
    end

    // Register 2: Store intermediate sums
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            for (int j = 0; j < size; j = j + 1) begin
                reg2[j] <= 8'b0;
            end
        end else begin
            for (int j = 0; j < size; j = j + 1) begin
                reg2[j] <= (j == 0) ? reg1[j] : reg2[j-1] + reg1[j];
            end
        end
    end

    // Final product calculation
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            mul_out <= 8'b0;
        end else begin
            mul_out <= reg2[size-1];
        end
    end

endmodule