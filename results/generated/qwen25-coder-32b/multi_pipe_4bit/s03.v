module multi_pipe_4bit (
    input wire clk,          // Clock signal
    input wire rst_n,        // Active-low reset signal
    input wire [3:0] mul_a,  // 4-bit multiplicand
    input wire [3:0] mul_b,  // 4-bit multiplier
    output wire [7:0] mul_out // 8-bit product
);

    parameter size = 4;

    // Extended input signals
    wire [7:0] ext_mul_a = {4'b0000, mul_a};
    wire [7:0] ext_mul_b = {4'b0000, mul_b};

    // Partial products
    wire [7:0] partial_product [0:size-1];

    // Intermediate sums
    reg [7:0] reg1 [0:size-1];
    reg [7:0] reg2 [0:size-1];

    // Final product
    reg [7:0] final_product;

    // Generate partial products
    genvar i;
    generate
        for (i = 0; i < size; i = i + 1) begin : gen_partial_product
            assign partial_product[i] = (mul_b[i]) ? (ext_mul_a << i) : 8'b00000000;
        end
    endgenerate

    // First level of registers
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            for (int j = 0; j < size; j = j + 1) begin
                reg1[j] <= 8'b00000000;
            end
        end else begin
            for (int j = 0; j < size; j = j + 1) begin
                reg1[j] <= partial_product[j];
            end
        end
    end

    // Second level of registers and addition
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            for (int j = 0; j < size; j = j + 1) begin
                reg2[j] <= 8'b00000000;
            end
            final_product <= 8'b00000000;
        end else begin
            for (int j = 0; j < size; j = j + 1) begin
                if (j == 0) begin
                    reg2[j] <= reg1[j];
                end else begin
                    reg2[j] <= reg2[j-1] + reg1[j];
                end
            end
            final_product <= reg2[size-1];
        end
    end

    // Assign final product to output
    assign mul_out = final_product;

endmodule