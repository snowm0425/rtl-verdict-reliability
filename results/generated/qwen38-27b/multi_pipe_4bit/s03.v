module multi_pipe_4bit #(
    parameter size = 4
) (
    input  wire        clk,
    input  wire        rst_n,
    input  wire [size-1:0] mul_a,
    input  wire [size-1:0] mul_b,
    output reg  [2*size-1:0] mul_out
);

    // Internal signals for pipeline stages
    wire [size-1:0] a_reg;
    wire [size-1:0] b_reg;
    
    // Extended multiplicand: pad with 'size' zero bits at MSB
    // Total width: 2*size bits
    wire [2*size-1:0] a_extended;
    
    // Partial products: one for each bit of mul_b
    // Each partial product has width 2*size
    wire [2*size-1:0] partial_products [0:size-1];
    
    // Registers to store partial products from Stage 1
    reg [2*size-1:0] pp_reg [0:size-1];
    
    // Intermediate sum for Stage 2
    wire [2*size-1:0] sum_pp;

    // --- Stage 1: Capture inputs and generate partial products ---
    
    // Register inputs for synchronization
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            a_reg <= {size{1'b0}};
            b_reg <= {size{1'b0}};
        end else begin
            a_reg <= mul_a;
            b_reg <= mul_b;
        end
    end

    // Extend mul_a by adding 'size' zero bits at MSB
    assign a_extended = { {size{1'b0}}, a_reg };

    // Generate partial products using a generate block
    genvar i;
    generate
        for (i = 0; i < size; i = i + 1) begin : gen_pp
            assign partial_products[i] = b_reg[i] ? (a_extended << i) : {2*size{1'b0}};
        end
    endgenerate

    // Store partial products in registers (Stage 1 output / Stage 2 input)
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            for (i = 0; i < size; i = i + 1) begin
                pp_reg[i] <= {2*size{1'b0}};
            end
        end else begin
            for (i = 0; i < size; i = i + 1) begin
                pp_reg[i] <= partial_products[i];
            end
        end
    end

    // --- Stage 2: Sum the partial products ---
    
    // Calculate the sum of all partial products
    // We can use a simple reduction adder
    reg [2*size-1:0] sum_temp;
    
    always @(*) begin
        sum_temp = {2*size{1'b0}};
        for (i = 0; i < size; i = i + 1) begin
            sum_temp = sum_temp + pp_reg[i];
        end
    end
    
    assign sum_pp = sum_temp;

    // Final output register
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            mul_out <= {2*size{1'b0}};
        end else begin
            mul_out <= sum_pp;
        end
    end

endmodule