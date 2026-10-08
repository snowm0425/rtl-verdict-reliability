module multi_pipe_8bit (
    input wire clk,           // Clock signal
    input wire rst_n,         // Active-low reset signal
    input wire mul_en_in,     // Input enable signal
    input wire [7:0] mul_a,   // Multiplicand
    input wire [7:0] mul_b,   // Multiplier
    output reg mul_en_out,    // Output enable signal
    output reg [15:0] mul_out // Product output
);

    // Registers for input enable, multiplicand, and multiplier
    reg mul_en_out_reg;
    reg [7:0] mul_a_reg;
    reg [7:0] mul_b_reg;

    // Registers for partial sums
    reg [15:0] sum1;
    reg [15:0] sum2;
    reg [15:0] sum3;
    reg [15:0] sum4;
    reg [15:0] sum5;
    reg [15:0] sum6;
    reg [15:0] sum7;

    // Register for final output product
    reg [15:0] mul_out_reg;

    // Wires for partial products
    wire [15:0] temp1;
    wire [15:0] temp2;
    wire [15:0] temp3;
    wire [15:0] temp4;
    wire [15:0] temp5;
    wire [15:0] temp6;
    wire [15:0] temp7;

    // Generate partial products
    assign temp1 = mul_b_reg[0] ? {8'b0, mul_a_reg} : 16'b0;
    assign temp2 = mul_b_reg[1] ? {7'b0, mul_a_reg, 1'b0} : 16'b0;
    assign temp3 = mul_b_reg[2] ? {6'b0, mul_a_reg, 2'b00} : 16'b0;
    assign temp4 = mul_b_reg[3] ? {5'b0, mul_a_reg, 3'b000} : 16'b0;
    assign temp5 = mul_b_reg[4] ? {4'b0, mul_a_reg, 4'b0000} : 16'b0;
    assign temp6 = mul_b_reg[5] ? {3'b0, mul_a_reg, 5'b00000} : 16'b0;
    assign temp7 = mul_b_reg[6] ? {2'b0, mul_a_reg, 6'b000000} : 16'b0;

    // Pipeline stages
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            // Reset all registers
            mul_en_out_reg <= 0;
            mul_a_reg <= 8'b0;
            mul_b_reg <= 8'b0;
            sum1 <= 16'b0;
            sum2 <= 16'b0;
            sum3 <= 16'b0;
            sum4 <= 16'b0;
            sum5 <= 16'b0;
            sum6 <= 16'b0;
            sum7 <= 16'b0;
            mul_out_reg <= 16'b0;
            mul_en_out <= 0;
        end else begin
            // Stage 1: Sample inputs
            if (mul_en_in) begin
                mul_en_out_reg <= 1;
                mul_a_reg <= mul_a;
                mul_b_reg <= mul_b;
            end else begin
                mul_en_out_reg <= 0;
            end

            // Stage 2: Calculate partial sums
            sum1 <= temp1;

            // Stage 3: Calculate partial sums
            sum2 <= sum1 + temp2;

            // Stage 4: Calculate partial sums
            sum3 <= sum2 + temp3;

            // Stage 5: Calculate partial sums
            sum4 <= sum3 + temp4;

            // Stage 6: Calculate partial sums
            sum5 <= sum4 + temp5;

            // Stage 7: Calculate partial sums
            sum6 <= sum5 + temp6;

            // Stage 8: Calculate final product
            sum7 <= sum6 + temp7;
            mul_out_reg <= sum7;

            // Output enable signal
            mul_en_out <= mul_en_out_reg;
        end
    end

    // Assign final output product
    assign mul_out = mul_en_out ? mul_out_reg : 16'b0;

endmodule