module freq_divbyodd #(
    parameter NUM_DIV = 5  // Must be an odd number
) (
    input clk,      // Input clock signal
    input rst_n,    // Active low reset signal
    output reg clk_div  // Divided clock output
);

    // Ensure NUM_DIV is odd
    initial begin
        if (NUM_DIV % 2 == 0) begin
            $error("NUM_DIV must be an odd number.");
            $stop;
        end
    end

    reg [15:0] cnt1;  // Counter for rising edge
    reg [15:0] cnt2;  // Counter for falling edge
    reg clk_div1;      // Clock divider for rising edge
    reg clk_div2;      // Clock divider for falling edge

    // Half of NUM_DIV (rounded down)
    localparam HALF_DIV = NUM_DIV / 2;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            cnt1 <= 0;
            cnt2 <= 0;
            clk_div1 <= 0;
            clk_div2 <= 0;
        end else begin
            // Handle rising edge of the clock
            if (cnt1 < NUM_DIV - 1) begin
                cnt1 <= cnt1 + 1;
            end else begin
                cnt1 <= 0;
            end

            // Handle falling edge of the clock
            if (cnt2 < NUM_DIV - 1) begin
                cnt2 <= cnt2 + 1;
            end else begin
                cnt2 <= 0;
            end

            // Toggle clk_div1 on rising edge when counter reaches half of NUM_DIV
            if (cnt1 == HALF_DIV) begin
                clk_div1 <= ~clk_div1;
            end

            // Toggle clk_div2 on falling edge when counter reaches half of NUM_DIV
            if (cnt2 == HALF_DIV) begin
                clk_div2 <= ~clk_div2;
            end
        end
    end

    // Final divided clock output is the logical OR of clk_div1 and clk_div2
    always @(*) begin
        clk_div = clk_div1 | clk_div2;
    end

endmodule