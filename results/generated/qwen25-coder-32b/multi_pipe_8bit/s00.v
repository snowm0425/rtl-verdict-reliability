module multi_pipe_8bit (
    input wire clk,            // Clock signal
    input wire rst_n,          // Active-low reset signal
    input wire mul_en_in,      // Input enable signal
    input wire [7:0] mul_a,    // Multiplicand
    input wire [7:0] mul_b,    // Multiplier
    output reg mul_en_out,     // Output enable signal
    output reg [15:0] mul_out  // Product output
);

    // Registers to store input enable, multiplicand, and multiplier
    reg mul_en_out_reg;
    reg [7:0] mul_a_reg;
    reg [7:0] mul_b_reg;

    // Partial products
    wire [7:0] temp [0:7];

    // Partial sums
    reg [8:0] sum [0:7];

    // Final product register
    reg [15:0] mul_out_reg;

    // Input control and register updates
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            mul_en_out_reg <= 0;
            mul_a_reg <= 0;
            mul_b_reg <= 0;
        end else begin
            if (mul_en_in) begin
                mul_en_out_reg <= 1;
                mul_a_reg <= mul_a;
                mul_b_reg <= mul_b;
            end
        end
    end

    // Generate partial products
    genvar i;
    generate
        for (i = 0; i < 8; i = i + 1) begin : gen_partial_products
            assign temp[i] = mul_b_reg[i] ? mul_a_reg : 8'b0;
        end
    endgenerate

    // Calculate partial sums
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            sum[0] <= 0;
        end else begin
            sum[0] <= {1'b0, temp[0]};
        end
    end

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            sum[1] <= 0;
        end else begin
            sum[1] <= sum[0] + {1'b0, temp[1]};
        end
    end

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            sum[2] <= 0;
        end else begin
            sum[2] <= sum[1] + {temp[2], 1'b0};
        end
    end

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            sum[3] <= 0;
        end else begin
            sum[3] <= sum[2] + {temp[3], 1'b0};
        end
    end

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            sum[4] <= 0;
        end else begin
            sum[4] <= sum[3] + {temp[4], 2'b00};
        end
    end

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            sum[5] <= 0;
        end else begin
            sum[5] <= sum[4] + {temp[5], 2'b00};
        end
    end

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            sum[6] <= 0;
        end else begin
            sum[6] <= sum[5] + {temp[6], 2'b00};
        end
    end

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            sum[7] <= 0;
        end else begin
            sum[7] <= sum[6] + {temp[7], 2'b00};
        end
    end

    // Final product calculation
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            mul_out_reg <= 0;
        end else begin
            mul_out_reg <= sum[7];
        end
    end

    // Output assignment
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            mul_en_out <= 0;
            mul_out <= 0;
        end else begin
            mul_en_out <= mul_en_out_reg;
            mul_out <= mul_en_out_reg ? mul_out_reg : 16'b0;
        end
    end

endmodule