module adder_pipe_64bit (
    input wire clk,          // Clock input
    input wire rst_n,        // Active low reset signal
    input wire i_en,         // Enable signal for addition operation
    input wire [63:0] adda,  // 64-bit input operand A
    input wire [63:0] addb,  // 64-bit input operand B
    output reg [64:0] result,// 65-bit output representing the sum of adda and addb
    output reg o_en          // Output enable signal
);

    // Internal registers for pipeline stages
    reg [63:0] adda_reg [0:4];
    reg [63:0] addb_reg [0:4];
    reg [64:0] sum_reg [0:4];
    reg i_en_reg [0:4];

    // Pipeline stage 0: Register inputs and enable signal
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            adda_reg[0] <= 64'b0;
            addb_reg[0] <= 64'b0;
            sum_reg[0] <= 65'b0;
            i_en_reg[0] <= 1'b0;
        end else begin
            adda_reg[0] <= adda;
            addb_reg[0] <= addb;
            sum_reg[0] <= 65'b0;
            i_en_reg[0] <= i_en;
        end
    end

    // Pipeline stages 1 to 4: Calculate partial sums and propagate carries
    genvar i;
    generate
        for (i = 1; i < 5; i = i + 1) begin : gen_pipeline_stages
            always @(posedge clk or negedge rst_n) begin
                if (!rst_n) begin
                    adda_reg[i] <= 64'b0;
                    addb_reg[i] <= 64'b0;
                    sum_reg[i] <= 65'b0;
                    i_en_reg[i] <= 1'b0;
                end else begin
                    adda_reg[i] <= adda_reg[i-1];
                    addb_reg[i] <= addb_reg[i-1];
                    i_en_reg[i] <= i_en_reg[i-1];

                    // Calculate the sum and carry for this stage
                    if (i == 1) begin
                        sum_reg[i] <= adda_reg[i-1] + addb_reg[i-1];
                    end else begin
                        sum_reg[i] <= adda_reg[i-1] + addb_reg[i-1] + sum_reg[i-1][63];
                    end
                end
            end
        end
    endgenerate

    // Output stage: Final result and output enable signal
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            result <= 65'b0;
            o_en <= 1'b0;
        end else begin
            result <= sum_reg[4];
            o_en <= i_en_reg[4];
        end
    end

endmodule