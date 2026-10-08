module multi_pipe_4bit #(
    parameter size = 4
) (
    input  wire              clk,
    input  wire              rst_n,
    input  wire [size-1:0]   mul_a,
    input  wire [size-1:0]   mul_b,
    output reg  [2*size-1:0] mul_out
);

    // Internal signals
    wire [2*size-1:0] partial_products [0:size-1];
    reg  [2*size-1:0] reg_partial      [0:size-1];

    // Generate partial products
    genvar i;
    generate
        for (i = 0; i < size; i = i + 1) begin : gen_partial
            // If mul_b[i] is 1, partial product is mul_a << i
            // Otherwise, 0
            assign partial_products[i] = mul_b[i] ? ({{size{1'b0}}, mul_a} << i) : {2*size{1'b0}};
        end
    endgenerate

    // First level of registers: Store the partial products
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            for (i = 0; i < size; i = i + 1) begin
                reg_partial[i] <= {2*size{1'b0}};
            end
        end else begin
            for (i = 0; i < size; i = i + 1) begin
                reg_partial[i] <= partial_products[i];
            end
        end
    end

    // Second level of registers: Sum the registered partial products and store in mul_out
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            mul_out <= {2*size{1'b0}};
        end else begin
            // Sum all reg_partial[i]
            reg [2*size-1:0] sum;
            sum = reg_partial[0];
            for (i = 1; i < size; i = i + 1) begin
                sum = sum + reg_partial[i];
            end
            mul_out <= sum;
        end
    end

endmodule