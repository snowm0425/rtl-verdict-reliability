module multi_pipe_8bit (
    input  wire        clk,
    input  wire        rst_n,
    input  wire        mul_en_in,
    input  wire [7:0]  mul_a,
    input  wire [7:0]  mul_b,
    output wire        mul_en_out,
    output wire [15:0] mul_out
);

    // Register for input enable signal
    reg mul_en_out_reg;
    
    // Registers for input operands
    reg [7:0] mul_a_reg;
    reg [7:0] mul_b_reg;
    
    // Partial product wires: each temp[i] is mul_a * mul_b[i] shifted left by i
    wire [15:0] temp [0:7];
    
    // Registers for partial sums
    reg [15:0] sum [0:7];
    
    // Register for final product
    reg [15:0] mul_out_reg;
    
    // Generate partial products
    genvar i;
    generate
        for (i = 0; i < 8; i = i + 1) begin : gen_partial_products
            assign temp[i] = mul_b[i] ? {mul_a, 8'b0} : 16'b0;
            // Actually, temp[i] should be mul_a shifted left by i, multiplied by mul_b[i]
            // So if mul_b[i] is 1, temp[i] = mul_a << i, else 0
            assign temp[i] = mul_b[i] ? {mul_a, 8'b0}[15:i] : 16'b0;
        end
    endgenerate
    
    // Correct partial product generation:
    // temp[i] = (mul_a * mul_b[i]) << i
    // Since mul_b[i] is 0 or 1, temp[i] = mul_a << i if mul_b[i] == 1, else 0
    
    // Let's redo the partial product generation properly
    generate
        for (i = 0; i < 8; i = i + 1) begin : gen_pp
            wire [15:0] shifted_a;
            assign shifted_a = {mul_a, 8'b0};
            assign temp[i] = mul_b[i] ? (shifted_a << i) : 16'b0;
        end
    endgenerate
    
    // Pipeline stage 1: Store input enable and operands
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            mul_en_out_reg <= 1'b0;
            mul_a_reg      <= 8'b0;
            mul_b_reg      <= 8'b0;
        end else begin
            mul_en_out_reg <= mul_en_in;
            if (mul_en_in) begin
                mul_a_reg <= mul_a;
                mul_b_reg <= mul_b;
            end
        end
    end
    
    // Pipeline stage 2: Compute partial sums
    // We'll sum all 8 partial products in this stage
    // To keep it simple and within the described architecture, we sum them all at once
    // using a tree or sequential addition. Given the description mentions "sum" registers,
    // let's use a single addition stage for clarity, but the description says "each register
    // corresponds to a group of partial products". For simplicity and correctness,
    // let's sum all partial products in one step into mul_out_reg.
    
    // Actually, re-reading: "Partial Sum Calculation" uses registers "sum" updated on clock.
    // "Final Product Calculation" sums all partial sums into mul_out_reg.
    // This implies at least 2 stages after input registration.
    
    // Let's implement:
    // Stage 1: Register inputs (done above)
    // Stage 2: Register partial products (sum registers)
    // Stage 3: Register final product
    
    // We need to adjust: the partial products should be based on registered inputs
    // Let's restructure:
    
    // Partial products from registered inputs
    wire [15:0] pp [0:7];
    generate
        for (i = 0; i < 8; i = i + 1) begin : gen_pp_reg
            assign pp[i] = mul_b_reg[i] ? ({mul_a_reg, 8'b0} << i) : 16'b0;
        end
    endgenerate
    
    // Sum registers: we'll store the sum of all partial products in one register
    // for simplicity, as the description is a bit ambiguous. But to follow "sum" as
    // multiple registers, let's create 8 sum registers each holding one partial product,
    // then in the final stage, sum them all.
    
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            for (integer j = 0; j < 8; j = j + 1) begin
                sum[j] <= 16'b0;
            end
        end else begin
            for (integer j = 0; j < 8; j = j + 1) begin
                sum[j] <= pp[j];
            end
        end
    end
    
    // Final product calculation: sum all partial sums
    wire [15:0] sum_total;
    assign sum_total = sum[0] + sum[1] + sum[2] + sum[3] + sum[4] + sum[5] + sum[6] + sum[7];
    
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            mul_out_reg <= 16'b0;
        end else begin
            mul_out_reg <= sum_total;
        end
    end
    
    // Output assignments
    assign mul_en_out = mul_en_out_reg;
    assign mul_out = mul_en_out ? mul_out_reg : 16'b0;

endmodule