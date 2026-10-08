module synchronizer (
    input  wire       clk_a,      // Clock signal A
    input  wire       clk_b,      // Clock signal B
    input  wire       arstn,      // Active-low reset for Domain A
    input  wire       brstn,      // Active-low reset for Domain B
    input  wire [3:0] data_in,    // 4-bit input data (Domain A)
    input  wire       data_en,    // Enable signal (Domain A)
    output reg  [3:0] dataout     // 4-bit output data (Domain B)
);

    // --- Domain A Registers ---
    // Latch input data and enable into Domain A registers
    // This ensures clean, stable signals for crossing to Domain B
    
    reg [3:0] data_reg;
    reg       en_data_reg;

    always @(posedge clk_a or negedge arstn) begin
        if (!arstn) begin
            data_reg    <= 4'b0000;
            en_data_reg <= 1'b0;
        end
        else begin
            data_reg    <= data_in;
            en_data_reg <= data_en;
        end
    end

    // --- Domain B Synchronization Chain ---
    // Synchronize the enable signal from Domain A to Domain B
    // Two-stage synchronizer for data_en
    
    reg en_clap_one;
    reg en_clap_two;

    always @(posedge clk_b or negedge brstn) begin
        if (!brstn) begin
            en_clap_one <= 1'b0;
            en_clap_two <= 1'b0;
        end
        else begin
            en_clap_one <= en_data_reg;
            en_clap_two <= en_clap_one;
        end
    end

    // --- Domain B Output Register ---
    // Update dataout when the delayed enable is active
    
    always @(posedge clk_b or negedge brstn) begin
        if (!brstn) begin
            dataout <= 4'b0000;
        end
        else begin
            if (en_clap_two) begin
                dataout <= data_reg;
            end
            // else: hold previous value
        end
    end

endmodule