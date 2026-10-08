module multi_pipe_8bit (
    input  wire       clk,
    input  wire       rst_n,
    input  wire       mul_en_in,
    input  wire [7:0] mul_a,
    input  wire [7:0] mul_b,
    output reg        mul_en_out,
    output reg [15:0] mul_out
);

    // Pipeline registers for inputs
    reg [7:0] mul_a_reg;
    reg [7:0] mul_b_reg;
    reg       mul_en_out_reg;

    // Partial product wires
    wire [15:0] temp0;
    wire [15:0] temp1;
    wire [15:0] temp2;
    wire [15:0] temp3;
    wire [15:0] temp4;
    wire [15:0] temp5;
    wire [15:0] temp6;
    wire [15:0] temp7;

    // Partial sum registers
    reg [15:0] sum0;
    reg [15:0] sum1;
    reg [15:0] sum2;
    reg [15:0] sum3;
    reg [15:0] sum4;
    reg [15:0] sum5;
    reg [15:0] sum6;
    reg [15:0] sum7;

    // Final product register
    reg [15:0] mul_out_reg;

    // Generate partial products
    assign temp0 = mul_b[0] ? {mul_a_reg, 8'd0} : 16'd0;
    assign temp1 = mul_b[1] ? {mul_a_reg, 7'd0, 1'b0} : 16'd0;
    assign temp2 = mul_b[2] ? {mul_a_reg, 6'd0, 2'b00} : 16'd0;
    assign temp3 = mul_b[3] ? {mul_a_reg, 5'd0, 3'b000} : 16'd0;
    assign temp4 = mul_b[4] ? {mul_a_reg, 4'd0, 4'b0000} : 16'd0;
    assign temp5 = mul_b[5] ? {mul_a_reg, 3'd0, 5'b00000} : 16'd0;
    assign temp6 = mul_b[6] ? {mul_a_reg, 2'd0, 6'b000000} : 16'd0;
    assign temp7 = mul_b[7] ? {mul_a_reg, 1'd0, 7'b0000000} : 16'd0;

    // Pipeline stage 1: sample inputs and enable
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            mul_a_reg      <= 8'd0;
            mul_b_reg      <= 8'd0;
            mul_en_out_reg <= 1'b0;
        end else begin
            mul_a_reg      <= mul_a;
            mul_b_reg      <= mul_b;
            mul_en_out_reg <= mul_en_in;
        end
    end

    // Pipeline stage 2: compute partial sums
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            sum0 <= 16'd0;
            sum1 <= 16'd0;
            sum2 <= 16'd0;
            sum3 <= 16'd0;
            sum4 <= 16'd0;
            sum5 <= 16'd0;
            sum6 <= 16'd0;
            sum7 <= 16'd0;
        end else begin
            sum0 <= temp0;
            sum1 <= temp1;
            sum2 <= temp2;
            sum3 <= temp3;
            sum4 <= temp4;
            sum5 <= temp5;
            sum6 <= temp6;
            sum7 <= temp7;
        end
    end

    // Pipeline stage 3: accumulate all partial sums into final product
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            mul_out_reg <= 16'd0;
        end else begin
            mul_out_reg <= sum0 + sum1 + sum2 + sum3 + sum4 + sum5 + sum6 + sum7;
        end
    end

    // Output assignment
    assign mul_en_out = mul_en_out_reg;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            mul_out <= 16'd0;
        end else begin
            if (mul_en_out_reg)
                mul_out <= mul_out_reg;
            else
                mul_out <= 16'd0;
        end
    end

endmodule