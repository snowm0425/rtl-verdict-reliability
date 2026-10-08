module synchronizer (
    input wire clk_a,          // Clock signal A
    input wire clk_b,          // Clock signal B
    input wire arstn,          // Active-low reset signal A
    input wire brstn,          // Active-low reset signal B
    input wire [3:0] data_in,  // Input data signal of size 4 bits
    input wire data_en,        // Input enable signal
    output reg [3:0] dataout   // Output data signal of size 4 bits
);

    // Registers to hold the input data and enable signal
    reg [3:0] data_reg;
    reg en_data_reg;

    // Control registers for synchronization
    reg en_clap_one;
    reg en_clap_two;

    // Data Register: Update on rising edge of clk_a or falling edge of arstn
    always @(posedge clk_a or negedge arstn) begin
        if (!arstn) begin
            data_reg <= 4'b0000;
        end else begin
            data_reg <= data_in;
        end
    end

    // Enable Data Register: Update on rising edge of clk_a or falling edge of arstn
    always @(posedge clk_a or negedge arstn) begin
        if (!arstn) begin
            en_data_reg <= 1'b0;
        end else begin
            en_data_reg <= data_en;
        end
    end

    // Enable Control Registers: Update on rising edge of clk_b or falling edge of brstn
    always @(posedge clk_b or negedge brstn) begin
        if (!brstn) begin
            en_clap_one <= 1'b0;
            en_clap_two <= 1'b0;
        end else begin
            en_clap_one <= en_data_reg;
            en_clap_two <= en_clap_one;
        end
    end

    // Output Assignment: Update on rising edge of clk_b or falling edge of brstn
    always @(posedge clk_b or negedge brstn) begin
        if (!brstn) begin
            dataout <= 4'b0000;
        end else if (en_clap_two) begin
            dataout <= data_reg;
        end
    end

endmodule