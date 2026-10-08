module multi_pipe_8bit (
    input wire clk,          // Clock signal
    input wire rst_n,        // Active-low reset signal
    input wire mul_en_in,    // Input enable signal
    input wire [7:0] mul_a,  // Multiplicand
    input wire [7:0] mul_b,  // Multiplier
    output reg mul_en_out,   // Output enable signal
    output reg [15:0] mul_out // Product output
);

    // Register to store the input enable signal
    reg mul_en_out_reg;

    // Registers to store the multiplicand and multiplier
    reg [7:0] mul_a_reg;
    reg [7:0] mul_b_reg;

    // Wires for partial products
    wire [15:0] temp [0:7];

    // Registers for partial sums
    reg [15:0] sum [0:6];

    // Register for the final product
    reg [15:0] mul_out_reg;

    // Input Control: Store mul_en_in in a register
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            mul_en_out_reg <= 0;
        end else begin
            mul_en_out_reg <= mul_en_in;
        end
    end

    // Input Registers: Store mul_a and mul_b when mul_en_in is active
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
            assign temp[i] = { (8'b0 >> i), mul_a_reg } & { 8'b0, {8{mul_b_reg[i]}} };
        end
    endgenerate

    // Partial Sum Calculation
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            sum[0] <= 16'b0;
            sum[1] <= 16'b0;
            sum[2] <= 16'b0;
            sum[3] <= 16'b0;
            sum[4] <= 16'b0;
            sum[5] <= 16'b0;
            sum[6] <= 16'b0;
        end else begin
            sum[0] <= temp[0] + temp[1];
            sum[1] <= sum[0] + temp[2];
            sum[2] <= sum[1] + temp[3];
            sum[3] <= sum[2] + temp[4];
            sum[4] <= sum[3] + temp[5];
            sum[5] <= sum[4] + temp[6];
            sum[6] <= sum[5] + temp[7];
        end
    end

    // Final Product Calculation
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            mul_out_reg <= 16'b0;
        end else begin
            mul_out_reg <= sum[6];
        end
    end

    // Output Assignment
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            mul_out <= 16'b0;
            mul_en_out <= 0;
        end else begin
            mul_out <= mul_out_reg;
            mul_en_out <= mul_en_out_reg;
        end
    end

endmodule