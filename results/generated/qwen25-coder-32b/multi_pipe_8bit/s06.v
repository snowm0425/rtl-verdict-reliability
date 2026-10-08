module multi_pipe_8bit (
    input wire clk,          // Clock signal
    input wire rst_n,        // Active-low reset signal
    input wire mul_en_in,    // Input enable signal
    input wire [7:0] mul_a,  // Multiplicand
    input wire [7:0] mul_b,  // Multiplier
    output reg mul_en_out,   // Output enable signal
    output reg [15:0] mul_out // Product output
);

    // Registers to store input enable, multiplicand, and multiplier
    reg mul_en_out_reg;
    reg [7:0] mul_a_reg;
    reg [7:0] mul_b_reg;

    // Partial products
    wire [7:0] temp [0:7];

    // Partial sum registers
    reg [8:0] sum [0:6];

    // Final product register
    reg [15:0] mul_out_reg;

    // Input control
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            mul_en_out_reg <= 0;
        end else begin
            mul_en_out_reg <= mul_en_in;
        end
    end

    // Input registers
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            mul_a_reg <= 8'b0;
            mul_b_reg <= 8'b0;
        end else if (mul_en_in) begin
            mul_a_reg <= mul_a;
            mul_b_reg <= mul_b;
        end
    end

    // Partial product generation
    genvar i;
    generate
        for (i = 0; i < 8; i = i + 1) begin : gen_temp
            assign temp[i] = (mul_b_reg[i]) ? mul_a_reg : 8'b0;
        end
    endgenerate

    // Partial sum calculation
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            for (int j = 0; j < 7; j = j + 1) begin
                sum[j] <= 9'b0;
            end
        end else begin
            sum[0] <= {1'b0, temp[0]};
            sum[1] <= sum[0] + {1'b0, temp[1]};
            sum[2] <= sum[1] + {1'b0, temp[2]};
            sum[3] <= sum[2] + {1'b0, temp[3]};
            sum[4] <= sum[3] + {1'b0, temp[4]};
            sum[5] <= sum[4] + {1'b0, temp[5]};
            sum[6] <= sum[5] + {1'b0, temp[6]};
        end
    end

    // Final product calculation
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            mul_out_reg <= 16'b0;
        end else begin
            mul_out_reg <= sum[6] + {1'b0, temp[7]};
        end
    end

    // Output assignment
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            mul_en_out <= 0;
            mul_out <= 16'b0;
        end else begin
            mul_en_out <= mul_en_out_reg;
            if (mul_en_out_reg) begin
                mul_out <= mul_out_reg;
            end else begin
                mul_out <= 16'b0;
            end
        end
    end

endmodule