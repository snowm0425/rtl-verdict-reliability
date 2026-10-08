module freq_divbyodd #(
    parameter NUM_DIV = 5  // Default divisor is 5
)(
    input wire clk,       // Input clock signal
    input wire rst_n,     // Active low reset signal
    output reg clk_div    // Divided clock output
);

    // Half of the divisor value
    localparam HALF_DIV = (NUM_DIV / 2);

    // Counters for tracking clock edges
    reg [31:0] cnt1;
    reg [31:0] cnt2;

    // Clock dividers for positive and negative edges
    reg clk_div1;
    reg clk_div2;

    // Reset logic
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            cnt1 <= 0;
            cnt2 <= 0;
            clk_div1 <= 0;
            clk_div2 <= 0;
            clk_div <= 0;
        end else begin
            // Counting rising edges
            if (cnt1 < NUM_DIV - 1) begin
                cnt1 <= cnt1 + 1;
            end else begin
                cnt1 <= 0;
                clk_div1 <= ~clk_div1;
            end

            // Counting falling edges
            if (cnt2 < NUM_DIV - 1) begin
                cnt2 <= cnt2 + 1;
            end else begin
                cnt2 <= 0;
                clk_div2 <= ~clk_div2;
            end

            // Final divided clock output
            clk_div <= clk_div1 | clk_div2;
        end
    end

endmodule