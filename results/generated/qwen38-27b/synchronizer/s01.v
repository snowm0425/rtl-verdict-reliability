module synchronizer (
    input  wire       clk_a,      // Clock A: input data and enable are referenced to this
    input  wire       clk_b,      // Clock B: output data and delayed enable are referenced to this
    input  wire       arstn,      // Active-low reset for Domain A
    input  wire       brstn,      // Active-low reset for Domain B
    input  wire [3:0] data_in,    // 4-bit input data
    input  wire       data_en,    // Enable signal
    output reg  [3:0] dataout     // 4-bit output data
);

    // -----------------------------------------------------------------------
    // Domain A Registers
    // -----------------------------------------------------------------------
    
    // Register to store the input data.
    // Updates on positive edge of clk_a or falling edge of arstn.
    reg [3:0] data_reg;
    
    always @(posedge clk_a or negedge arstn) begin
        if (!arstn) begin
            data_reg <= 4'b0000;
        end else begin
            data_reg <= data_in;
        end
    end

    // Register to store the input enable signal.
    // Updates on positive edge of clk_a or falling edge of arstn.
    reg en_data_reg;
    
    always @(posedge clk_a or negedge arstn) begin
        if (!arstn) begin
            en_data_reg <= 1'b0;
        end else begin
            en_data_reg <= data_en;
        end
    end

    // -----------------------------------------------------------------------
    // Domain B Registers
    // -----------------------------------------------------------------------
    
    // First stage of the 2-cycle enable delay in Domain B.
    // Samples en_data_reg from Domain A.
    reg en_clap_one;
    
    always @(posedge clk_b or negedge brstn) begin
        if (!brstn) begin
            en_clap_one <= 1'b0;
        end else begin
            en_clap_one <= en_data_reg;
        end
    end

    // Second stage of the 2-cycle enable delay in Domain B.
    // Samples en_clap_one.
    reg en_clap_two;
    
    always @(posedge clk_b or negedge brstn) begin
        if (!brstn) begin
            en_clap_two <= 1'b0;
        end else begin
            en_clap_two <= en_clap_one;
        end
    end

    // Output Register
    // Updates on positive edge of clk_b or falling edge of brstn.
    // If brstn is low, output is 0.
    // If brstn is high and en_clap_two is active (1), output takes data_reg.
    // Otherwise, output retains its previous value.
    always @(posedge clk_b or negedge brstn) begin
        if (!brstn) begin
            dataout <= 4'b0000;
        end else begin
            if (en_clap_two) begin
                dataout <= data_reg;
            end else begin
                // Retain previous value
                dataout <= dataout;
            end
        end
    end

endmodule