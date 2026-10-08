module multi_pipe_4bit (
    input clk,                // Clock signal used for synchronous operation.
    input rst_n,              // Active-low reset signal.
    input [3:0] mul_a,        // Multiplicand input (4 bits).
    input [3:0] mul_b,        // Multiplier input (4 bits).
    output reg [7:0] mul_out  // Product output (8 bits).
);

    parameter size = 4;

    // Registers to store intermediate sums
    reg [7:0] reg1;
    reg [7:0] reg2;

    // Extended multiplicand
    wire [7:0] ext_mul_a = {4'b0000, mul_a};

    // Partial products
    wire [7:0] partial_product [0:size-1];

    // Generate partial products
    genvar i;
    generate
        for (i = 0; i < size; i = i + 1) begin : gen_partial_product
            assign partial_product[i] = (mul_b[i] == 1'b1) ? (ext_mul_a << i) : 8'b00000000;
        end
    endgenerate

    // First level of addition (register 1)
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            reg1 <= 8'b00000000;
        end else begin
            reg1 <= partial_product[0] + partial_product[1];
        end
    end

    // Second level of addition (register 2)
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            reg2 <= 8'b00000000;
        end else begin
            reg2 <= reg1 + partial_product[2] + partial_product[3];
        end
    end

    // Final output assignment
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            mul_out <= 8'b00000000;
        end else begin
            mul_out <= reg2;
        end
    end

endmodule