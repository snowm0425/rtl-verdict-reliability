module multi_pipe_8bit (
    input clk,              // Clock signal
    input rst_n,            // Active-low reset signal
    input mul_en_in,        // Input enable signal
    input [7:0] mul_a,      // Multiplicand
    input [7:0] mul_b,      // Multiplier
    output mul_en_out,      // Output enable signal
    output [15:0] mul_out   // Product output
);

    // Registers for input enable and output enable
    reg mul_en_out_reg;
    reg mul_en_out_reg_d1;
    reg mul_en_out_reg_d2;

    // Registers to store multiplicand and multiplier
    reg [7:0] mul_a_reg;
    reg [7:0] mul_b_reg;

    // Intermediate registers for partial products and sums
    reg [15:0] sum_reg_1;
    reg [15:0] sum_reg_2;

    // Final product register
    reg [15:0] mul_out_reg;

    // Temporary wires for partial products
    wire [15:0] temp;

    // Generate partial products
    generate
        genvar i;
        for (i = 0; i < 8; i = i + 1) begin : partial_products
            assign temp[i] = mul_a_reg[i] & mul_b_reg[0];
        end
    endgenerate

    // Pipeline stages
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            mul_en_out_reg <= 0;
            mul_en_out_reg_d1 <= 0;
            mul_en_out_reg_d2 <= 0;
            mul_a_reg <= 0;
            mul_b_reg <= 0;
            sum_reg_1 <= 0;
            sum_reg_2 <= 0;
            mul_out_reg <= 0;
        end else begin
            // Stage 1: Sample inputs and generate partial products
            mul_en_out_reg <= mul_en_in;
            if (mul_en_in) begin
                mul_a_reg <= mul_a;
                mul_b_reg <= mul_b;
            end

            // Stage 2: Calculate first partial sum
            mul_en_out_reg_d1 <= mul_en_out_reg;
            if (mul_en_out_reg) begin
                sum_reg_1 <= {temp[7:0], 8'b0} + ({8'b0, temp[7:0]} << 1);
            end

            // Stage 3: Calculate second partial sum
            mul_en_out_reg_d2 <= mul_en_out_reg_d1;
            if (mul_en_out_reg_d1) begin
                sum_reg_2 <= sum_reg_1 + ({temp[7:0], 8'b0} << 2);
            end

            // Final stage: Calculate final product
            if (mul_en_out_reg_d2) begin
                mul_out_reg <= sum_reg_2 + ({temp[7:0], 8'b0} << 3);
            end
        end
    end

    // Output enable signal
    assign mul_en_out = mul_en_out_reg_d2;

    // Output product
    assign mul_out = mul_en_out_reg_d2 ? mul_out_reg : 16'b0;

endmodule