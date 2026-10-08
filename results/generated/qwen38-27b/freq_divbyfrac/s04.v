module freq_divbyfrac (
    input  wire clk,
    input  wire rst_n,
    output wire clk_div
);

    // Internal signals
    reg [2:0] counter;
    reg clk_div_pos; // Rising edge triggered divided clock
    reg clk_div_neg; // Falling edge triggered divided clock
    reg clk_div_pos_d1;
    reg clk_div_neg_d1;
    reg clk_div_pos_d2;
    reg clk_div_neg_d2;

    // Counter for 3.5x division: cycles through 0 to 6 (7 states)
    // On rising edge of clk
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            counter <= 3'd0;
        end else begin
            if (counter == 3'd6) begin
                counter <= 3'd0;
            end else begin
                counter <= counter + 1'b1;
            end
        end
    end

    // Generate intermediate clocks on both rising and falling edges
    // For 3.5x division, we need to create two phases that are offset by half a clock cycle
    
    // Rising edge triggered logic
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            clk_div_pos <= 1'b0;
            clk_div_pos_d1 <= 1'b0;
            clk_div_pos_d2 <= 1'b0;
        end else begin
            clk_div_pos_d1 <= clk_div_pos;
            clk_div_pos_d2 <= clk_div_pos_d1;
            
            // Generate rising-edge divided clock: high for 4 cycles, low for 3 cycles
            // Pattern: 4 high, 3 low over 7 cycles
            case (counter)
                3'd0: clk_div_pos <= 1'b1;
                3'd3: clk_div_pos <= 1'b0;
                default: clk_div_pos <= clk_div_pos;
            endcase
        end
    end

    // Falling edge triggered logic
    always @(negedge clk or negedge rst_n) begin
        if (!rst_n) begin
            clk_div_neg <= 1'b0;
            clk_div_neg_d1 <= 1'b0;
            clk_div_neg_d2 <= 1'b0;
        end else begin
            clk_div_neg_d1 <= clk_div_neg;
            clk_div_neg_d2 <= clk_div_neg_d1;
            
            // Generate falling-edge divided clock: phase shifted by half a clock
            // To achieve half-cycle phase shift, we toggle on different points
            // For 3.5x: the falling-edge clock should be offset by 1/2 of source clock
            // Pattern: high for 3.5 cycles equivalent, but we approximate with edge-triggered logic
            // Using counter on falling edge, we can create a complementary pattern
            case (counter)
                3'd0: clk_div_neg <= 1'b1;
                3'd3: clk_div_neg <= 1'b0;
                default: clk_div_neg <= clk_div_neg;
            endcase
        end
    end

    // Combine the two phase-shifted clocks using OR to get uniform duty cycle
    assign clk_div = clk_div_pos | clk_div_neg;

endmodule