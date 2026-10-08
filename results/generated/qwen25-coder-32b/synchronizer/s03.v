module synchronizer (
    input clk_a,          // Clock signal A
    input clk_b,          // Clock signal B
    input arstn,          // Active-low reset signal A
    input brstn,          // Active-low reset signal B
    input [3:0] data_in,  // 4-bit input data signal
    input data_en,        // Input enable signal
    
    output reg [3:0] dataout // 4-bit output data signal
);

    // Registers to store data and enable signals
    reg [3:0] data_reg;
    reg en_data_reg;
    
    // Registers for enable control (two D flip-flops)
    reg en_clap_one;
    reg en_clap_two;

    // Data Register: update on the positive edge of clk_a or falling edge of arstn
    always @(posedge clk_a or negedge arstn) begin
        if (!arstn) begin
            data_reg <= 4'b0;
        end else begin
            data_reg <= data_in;
        end
    end

    // Enable Data Register: update on the positive edge of clk_a or falling edge of arstn
    always @(posedge clk_a or negedge arstn) begin
        if (!arstn) begin
            en_data_reg <= 1'b0;
        end else begin
            en_data_reg <= data_en;
        end
    end

    // Enable Control Registers: update on the positive edge of clk_b or falling edge of brstn
    always @(posedge clk_b or negedge brstn) begin
        if (!brstn) begin
            en_clap_one <= 1'b0;
            en_clap_two <= 1'b0;
        end else begin
            en_clap_one <= en_data_reg;
            en_clap_two <= en_clap_one;
        end
    end

    // Output Assignment: update on the positive edge of clk_b or falling edge of brstn
    always @(posedge clk_b or negedge brstn) begin
        if (!brstn) begin
            dataout <= 4'b0;
        end else if (en_clap_two) begin
            dataout <= data_reg;
        end
    end

endmodule