module freq_divbyodd #(
    parameter NUM_DIV = 5  // Default divisor value
)(
    input wire clk,         // Input clock signal
    input wire rst_n,       // Active low reset signal
    output reg clk_div      // Divided clock output
);

    // Ensure NUM_DIV is an odd number
    generate
        if (NUM_DIV % 2 == 0) begin : even_divisor_check
            initial begin
                $fatal("NUM_DIV must be an odd number.");
            end
        end
    endgenerate

    // Counters for rising and falling edges
    reg [$clog2(NUM_DIV)-1:0] cnt1; // Counter for rising edge
    reg [$clog2(NUM_DIV)-1:0] cnt2; // Counter for falling edge

    // Clock dividers for positive and negative edges
    reg clk_div1; // Divided clock for rising edge
    reg clk_div2; // Divided clock for falling edge

    // Half divisor value
    localparam HALF_DIV = NUM_DIV / 2;

    // State machine to handle clock division
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            // Reset counters and clock dividers
            cnt1 <= 0;
            cnt2 <= 0;
            clk_div1 <= 0;
            clk_div2 <= 0;
        end else begin
            // Handle rising edge
            if (cnt1 == NUM_DIV - 1) begin
                cnt1 <= 0;
                clk_div1 <= ~clk_div1;
            end else if (cnt1 == HALF_DIV - 1) begin
                cnt1 <= cnt1 + 1;
            end else begin
                cnt1 <= cnt1 + 1;
            end

            // Handle falling edge
            if (cnt2 == NUM_DIV - 1) begin
                cnt2 <= 0;
                clk_div2 <= ~clk_div2;
            end else if (cnt2 == HALF_DIV - 1) begin
                cnt2 <= cnt2 + 1;
            end else begin
                cnt2 <= cnt2 + 1;
            end
        end
    end

    // Final divided clock output
    assign clk_div = clk_div1 | clk_div2;

endmodule