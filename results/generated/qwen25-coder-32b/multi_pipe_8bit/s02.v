module multi_pipe_8bit (
    input clk,          // Clock signal
    input rst_n,        // Active-low reset signal
    input mul_en_in,    // Input enable signal
    input [7:0] mul_a,  // 8-bit multiplicand
    input [7:0] mul_b,  // 8-bit multiplier
    output mul_en_out,  // Output enable signal
    output [15:0] mul_out // 16-bit product output
);

    // Internal registers
    reg mul_en_out_reg;
    reg [7:0] mul_a_reg;
    reg [7:0] mul_b_reg;
    reg [15:0] mul_out_reg;
    
    // Partial product generation
    wire [7:0] temp [0:7];
    
    // Partial sum calculation
    reg [15:0] sum [0:7];
    
    // Generate partial products
    genvar i;
    generate
        for (i = 0; i < 8; i = i + 1) begin : gen_partial_products
            assign temp[i] = (mul_b_reg[i] == 1'b1) ? mul_a_reg : 8'b0;
        end
    endgenerate
    
    // Pipeline stages for partial sum calculation
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            for (int j = 0; j < 8; j = j + 1) begin
                sum[j] <= 16'b0;
            end
            mul_a_reg <= 8'b0;
            mul_b_reg <= 8'b0;
            mul_en_out_reg <= 1'b0;
        end else begin
            if (mul_en_in) begin
                mul_a_reg <= mul_a;
                mul_b_reg <= mul_b;
            end
            
            // First stage: sum[0] = temp[0]
            if (mul_en_in)
                sum[0] <= {8'b0, temp[0]};
            
            // Subsequent stages: sum[i] = sum[i-1] + temp[i]
            for (int j = 1; j < 8; j = j + 1) begin
                sum[j] <= sum[j-1] + {8'b0, temp[j]};
            end
            
            // Output enable signal pipeline
            mul_en_out_reg <= mul_en_in;
        end
    end
    
    // Final product calculation and output assignment
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            mul_out_reg <= 16'b0;
        end else begin
            // Store the final sum in mul_out_reg
            mul_out_reg <= sum[7];
        end
    end
    
    // Output enable signal
    assign mul_en_out = mul_en_out_reg;
    
    // Output product value
    assign mul_out = mul_en_out_reg ? mul_out_reg : 16'b0;

endmodule