module synchronizer (
    input wire clk_a,        // Clock signal A
    input wire clk_b,        // Clock signal B
    input wire arstn,        // Active-low reset signal A
    input wire brstn,        // Active-low reset signal B
    input wire [3:0] data_in, // 4-bit input data signal
    input wire data_en,      // Input enable signal
    output reg [3:0] dataout // 4-bit output data signal
);

    // Registers to store input data and enable signal
    reg [3:0] data_reg;
    reg en_data_reg;

    // Registers to control the selection of input data
    reg en_clap_one;
    reg en_clap_two;

    // Register to store the output data
    reg [3:0] dataout_reg;

    // Process to update data_reg and en_data_reg on the positive edge of clk_a or falling edge of arstn
    always @(posedge clk_a or negedge arstn) begin
        if (!arstn) begin
            data_reg <= 4'b0000;
            en_data_reg <= 1'b0;
        end else begin
            data_reg <= data_in;
            en_data_reg <= data_en;
        end
    end

    // Process to update en_clap_one and en_clap_two on the positive edge of clk_b or falling edge of brstn
    always @(posedge clk_b or negedge brstn) begin
        if (!brstn) begin
            en_clap_one <= 1'b0;
            en_clap_two <= 1'b0;
        end else begin
            en_clap_one <= en_data_reg;
            en_clap_two <= en_clap_one;
        end
    end

    // Process to assign the output data value on the positive edge of clk_b or falling edge of brstn
    always @(posedge clk_b or negedge brstn) begin
        if (!brstn) begin
            dataout_reg <= 4'b0000;
        end else if (en_clap_two) begin
            dataout_reg <= data_reg;
        end
    end

    // Continuous assignment to drive the output
    assign dataout = dataout_reg;

endmodule