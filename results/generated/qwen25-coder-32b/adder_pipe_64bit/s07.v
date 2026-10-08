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
    localparam STAGES = 4;
    localparam WIDTH = 64 / STAGES;

    // Internal registers to hold partial sums and carries
    reg [WIDTH-1:0] adda_reg [0:STAGES];
    reg [WIDTH-1:0] addb_reg [0:STAGES];
    reg [WIDTH:0] sum_reg [0:STAGES];
    reg [WIDTH-1:0] carry_reg [0:STAGES];

    // Pipeline stages
    genvar i;
    generate
        for (i = 0; i <= STAGES; i = i + 1) begin : pipe_stages
            // Initial pipeline stage
            if (i == 0) begin
                always @(posedge clk or negedge rst_n) begin
                    if (!rst_n) begin
                        adda_reg[0] <= 0;
                        addb_reg[0] <= 0;
                        sum_reg[0] <= 0;
                        carry_reg[0] <= 0;
                    end else if (i_en) begin
                        adda_reg[0] <= adda[WIDTH-1:0];
                        addb_reg[0] <= addb[WIDTH-1:0];
                        {sum_reg[0], carry_reg[0]} <= adda[WIDTH-1:0] + addb[WIDTH-1:0];
                    end
                end
            end
            // Middle pipeline stages
            else if (i < STAGES) begin
                always @(posedge clk or negedge rst_n) begin
                    if (!rst_n) begin
                        adda_reg[i] <= 0;
                        addb_reg[i] <= 0;
                        sum_reg[i] <= 0;
                        carry_reg[i] <= 0;
                    end else begin
                        adda_reg[i] <= adda[i*WIDTH + WIDTH-1:i*WIDTH];
                        addb_reg[i] <= addb[i*WIDTH + WIDTH-1:i*WIDTH];
                        {sum_reg[i], carry_reg[i]} <= adda[i*WIDTH + WIDTH-1:i*WIDTH] + addb[i*WIDTH + WIDTH-1:i*WIDTH] + carry_reg[i-1];
                    end
                end
            end
            // Final pipeline stage
            else begin
                always @(posedge clk or negedge rst_n) begin
                    if (!rst_n) begin
                        sum_reg[i] <= 0;
                        o_en <= 0;
                    end else begin
                        sum_reg[i] <= adda[63:(STAGES-1)*WIDTH] + addb[63:(STAGES-1)*WIDTH] + carry_reg[i-1];
                        o_en <= i_en;
                    end
                end
            end
        end
    endgenerate

    // Final result assignment
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            result <= 0;
        end else if (o_en) begin
            result <= {sum_reg[STAGES][WIDTH-1], sum_reg[STAGES]};
        end
    end

endmodule