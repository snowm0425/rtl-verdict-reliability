module multi_pipe_4bit #(
    parameter size = 4
) (
    input  wire                  clk,
    input  wire                  rst_n,
    input  wire [size-1:0]       mul_a,
    input  wire [size-1:0]       mul_b,
    output reg  [2*size-1:0]     mul_out
);

    // Extend inputs by adding 'size' zero bits at MSB positions
    // So extended width is 2*size bits
    wire [2*size-1:0] mul_a_ext;
    wire [2*size-1:0] mul_b_ext;

    assign mul_a_ext = { {size{1'b0}}, mul_a };
    assign mul_b_ext = { {size{1'b0}}, mul_b };

    // Generate partial products
    // For each bit i of mul_b (0 to size-1), partial product is:
    //   if mul_b[i] == 1, then mul_a_ext << i
    //   else 0
    // Each partial product is 2*size bits wide

    wire [2*size-1:0] partial_prods [0:size-1];

    genvar i;
    generate
        for (i = 0; i < size; i = i + 1) begin : gen_partial
            assign partial_prods[i] = mul_b[i] ? (mul_a_ext << i) : {2*size{1'b0}};
        end
    endgenerate

    // Two levels of registers to store intermediate values
    // Level 1: store partial products
    // Level 2: store accumulated sums

    // Register level 1: store each partial product
    reg [2*size-1:0] pp_reg [0:size-1];

    // Register level 2: store intermediate sum values
    // We need to add all size partial products.
    // Let's use a tree-like or sequential addition approach.
    // Since it's a pipeline, let's have two stages of addition.

    // Stage 1: Add pairs of partial products
    // For size=4, we have 4 partial products.
    // Stage 1: add pp[0]+pp[1], pp[2]+pp[3]
    // Stage 2: add the two results from Stage 1

    // Let's define intermediate registers for stage 1
    reg [2*size-1:0] stage1_sum [0:(size/2)-1];
    // For size=4, size/2 = 2, so stage1_sum[0] and stage1_sum[1]

    // Stage 2: final sum
    reg [2*size-1:0] stage2_sum;

    integer j;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            for (j = 0; j < size; j = j + 1) begin
                pp_reg[j] <= {2*size{1'b0}};
            end
            for (j = 0; j < (size/2); j = j + 1) begin
                stage1_sum[j] <= {2*size{1'b0}};
            end
            stage2_sum <= {2*size{1'b0}};
            mul_out <= {2*size{1'b0}};
        end else begin
            // Level 1: store partial products
            for (j = 0; j < size; j = j + 1) begin
                pp_reg[j] <= partial_prods[j];
            end

            // Level 2: Stage 1 - add pairs
            for (j = 0; j < (size/2); j = j + 1) begin
                stage1_sum[j] <= pp_reg[2*j] + pp_reg[2*j+1];
            end

            // Level 3: Stage 2 - add the stage1 results
            // For size=4, we have 2 stage1 sums
            if (size/2 == 2) begin
                stage2_sum <= stage1_sum[0] + stage1_sum[1];
            end else if (size/2 == 1) begin
                stage2_sum <= stage1_sum[0];
            end

            // Final output
            mul_out <= stage2_sum;
        end
    end

endmodule