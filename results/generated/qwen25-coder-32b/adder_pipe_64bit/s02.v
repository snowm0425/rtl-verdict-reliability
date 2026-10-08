module adder_pipe_64bit (
    input wire clk,
    input wire rst_n,
    input wire i_en,
    input wire [63:0] adda,
    input wire [63:0] addb,
    output reg [64:0] result,
    output reg o_en
);

    // Define the number of pipeline stages
    localparam NUM_STAGES = 4;
    
    // Internal registers for pipeline stages
    reg [63:0] adda_reg [NUM_STAGES:0];
    reg [63:0] addb_reg [NUM_STAGES:0];
    reg [64:0] sum_reg [NUM_STAGES:0];
    reg i_en_reg [NUM_STAGES:0];

    // Initial stage assignment
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            for (integer i = 0; i <= NUM_STAGES; i = i + 1) begin
                adda_reg[i] <= 64'b0;
                addb_reg[i] <= 64'b0;
                sum_reg[i] <= 65'b0;
                i_en_reg[i] <= 1'b0;
            end
        end else begin
            adda_reg[0] <= adda;
            addb_reg[0] <= addb;
            i_en_reg[0] <= i_en;

            // Pipeline stages
            for (integer i = 1; i <= NUM_STAGES; i = i + 1) begin
                adda_reg[i] <= adda_reg[i-1];
                addb_reg[i] <= addb_reg[i-1];
                i_en_reg[i] <= i_en_reg[i-1];
            end

            // Calculate sum for each stage
            sum_reg[1] <= {1'b0, adda_reg[0]} + {1'b0, addb_reg[0]};
            for (integer i = 2; i <= NUM_STAGES; i = i + 1) begin
                sum_reg[i] <= sum_reg[i-1][63:0] + {1'b0, adda_reg[i-1]}[63:0];
            end

            // Final result and output enable
            result <= sum_reg[NUM_STAGES];
            o_en <= i_en_reg[NUM_STAGES];
        end
    end

endmodule