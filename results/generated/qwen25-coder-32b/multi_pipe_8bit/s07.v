module multi_pipe_8bit (
    input wire clk,           // Clock signal
    input wire rst_n,         // Active-low reset signal
    input wire mul_en_in,     // Input enable signal
    input wire [7:0] mul_a,   // Multiplicand (8 bits)
    input wire [7:0] mul_b,   // Multiplier (8 bits)
    output wire mul_en_out,   // Output enable signal
    output wire [15:0] mul_out // Product output (16 bits)
);

    // Registers to store input enable, multiplicand, and multiplier
    reg mul_en_out_reg;
    reg [7:0] mul_a_reg;
    reg [7:0] mul_b_reg;

    // Registers to store intermediate sums
    reg [8:0] sum1;
    reg [9:0] sum2;
    reg [10:0] sum3;
    reg [11:0] sum4;
    reg [12:0] sum5;
    reg [13:0] sum6;
    reg [14:0] sum7;

    // Register to store the final product
    reg [15:0] mul_out_reg;

    // Input Registers
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            mul_en_out_reg <= 0;
            mul_a_reg <= 8'b0;
            mul_b_reg <= 8'b0;
        end else if (mul_en_in) begin
            mul_en_out_reg <= 1;
            mul_a_reg <= mul_a;
            mul_b_reg <= mul_b;
        end
    end

    // Partial Product Generation and Partial Sum Calculation
    wire [8:0] temp0 = mul_b_reg[0] ? {1'b0, mul_a_reg} : 9'b0;
    wire [8:0] temp1 = mul_b_reg[1] ? {1'b0, mul_a_reg} << 1 : 9'b0;
    wire [8:0] temp2 = mul_b_reg[2] ? {1'b0, mul_a_reg} << 2 : 9'b0;
    wire [8:0] temp3 = mul_b_reg[3] ? {1'b0, mul_a_reg} << 3 : 9'b0;
    wire [8:0] temp4 = mul_b_reg[4] ? {1'b0, mul_a_reg} << 4 : 9'b0;
    wire [8:0] temp5 = mul_b_reg[5] ? {1'b0, mul_a_reg} << 5 : 9'b0;
    wire [8:0] temp6 = mul_b_reg[6] ? {1'b0, mul_a_reg} << 6 : 9'b0;
    wire [8:0] temp7 = mul_b_reg[7] ? {1'b0, mul_a_reg} << 7 : 9'b0;

    // Pipeline stages for partial sums
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            sum1 <= 9'b0;
            sum2 <= 10'b0;
            sum3 <= 11'b0;
            sum4 <= 12'b0;
            sum5 <= 13'b0;
            sum6 <= 14'b0;
            sum7 <= 15'b0;
            mul_out_reg <= 16'b0;
        end else begin
            sum1 <= temp0 + temp1;
            sum2 <= sum1 + temp2;
            sum3 <= sum2 + temp3;
            sum4 <= sum3 + temp4;
            sum5 <= sum4 + temp5;
            sum6 <= sum5 + temp6;
            sum7 <= sum6 + temp7;
            mul_out_reg <= sum7;
        end
    end

    // Output Assignment
    assign mul_en_out = mul_en_out_reg;
    assign mul_out = mul_en_out_reg ? mul_out_reg : 16'b0;

endmodule