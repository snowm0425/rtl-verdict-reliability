module multi_pipe_8bit (
    input clk,          // Clock signal used for synchronous operation
    input rst_n,        // Active-low reset signal
    input mul_en_in,    // Input enable signal
    input [7:0] mul_a,  // Multiplicand
    input [7:0] mul_b,  // Multiplier
    output mul_en_out,  // Output enable signal
    output [15:0] mul_out // Product output
);

    // Internal registers
    reg mul_en_out_reg;
    reg [7:0] mul_a_reg;
    reg [7:0] mul_b_reg;
    reg [15:0] mul_out_reg;
    reg [15:0] sum [0:7]; // Array of sum registers for partial sums

    // Wires for partial products
    wire [15:0] temp [0:7];

    // Input Control
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            mul_en_out_reg <= 0;
        end else begin
            mul_en_out_reg <= mul_en_in;
        end
    end

    // Input Registers
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            mul_a_reg <= 8'b0;
            mul_b_reg <= 8'b0;
        end else if (mul_en_in) begin
            mul_a_reg <= mul_a;
            mul_b_reg <= mul_b;
        end
    end

    // Partial Product Generation
    genvar i;
    generate
        for (i = 0; i < 8; i = i + 1) begin : gen_partial_products
            assign temp[i] = {8'b0, mul_a_reg} << i & { {8{mul_b_reg[i]}}, 8'b0 };
        end
    endgenerate

    // Partial Sum Calculation
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            for (int j = 0; j < 8; j = j + 1) begin
                sum[j] <= 16'b0;
            end
        end else begin
            sum[0] <= temp[0];
            for (int j = 1; j < 8; j = j + 1) begin
                sum[j] <= sum[j-1] + temp[j];
            end
        end
    end

    // Final Product Calculation
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            mul_out_reg <= 16'b0;
        end else begin
            mul_out_reg <= sum[7];
        end
    end

    // Output Assignment
    assign mul_en_out = mul_en_out_reg;
    assign mul_out = mul_en_out_reg ? mul_out_reg : 16'b0;

endmodule