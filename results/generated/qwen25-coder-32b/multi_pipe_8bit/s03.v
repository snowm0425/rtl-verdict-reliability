module multi_pipe_8bit (
    input wire clk,          // Clock signal
    input wire rst_n,        // Active-low reset signal
    input wire mul_en_in,    // Input enable signal
    input wire [7:0] mul_a,  // Multiplicand
    input wire [7:0] mul_b,  // Multiplier
    output wire mul_en_out,  // Output enable signal
    output wire [15:0] mul_out // Product output
);

    // Registers to store input enable, multiplicand, and multiplier
    reg mul_en_out_reg;
    reg [7:0] mul_a_reg;
    reg [7:0] mul_b_reg;

    // Temporary storage for partial products
    wire [7:0] temp [0:7];

    // Registers to store intermediate sums
    reg [8:0] sum [0:7];

    // Register to store the final product
    reg [15:0] mul_out_reg;

    // Input Control: Register the input enable signal
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            mul_en_out_reg <= 0;
        end else begin
            mul_en_out_reg <= mul_en_in;
        end
    end

    // Input Registers: Register the multiplicand and multiplier
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            mul_a_reg <= 0;
            mul_b_reg <= 0;
        end else if (mul_en_in) begin
            mul_a_reg <= mul_a;
            mul_b_reg <= mul_b;
        end
    end

    // Partial Product Generation
    genvar i;
    generate
        for (i = 0; i < 8; i = i + 1) begin : gen_partial_products
            assign temp[i] = mul_a_reg & {8{mul_b_reg[i]}};
        end
    endgenerate

    // Partial Sum Calculation
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            for (int j = 0; j < 8; j = j + 1) begin
                sum[j] <= 0;
            end
        end else begin
            sum[0] <= {1'b0, temp[0]};
            for (int j = 1; j < 8; j = j + 1) begin
                sum[j] <= sum[j-1] + {1'b0, temp[j]};
            end
        end
    end

    // Final Product Calculation
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            mul_out_reg <= 0;
        end else begin
            mul_out_reg <= sum[7];
        end
    end

    // Output Assignment
    assign mul_en_out = mul_en_out_reg;
    assign mul_out = mul_en_out_reg ? mul_out_reg : 16'b0;

endmodule