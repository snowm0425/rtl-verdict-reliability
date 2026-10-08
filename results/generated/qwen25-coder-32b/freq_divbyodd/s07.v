module freq_divbyodd #(
    parameter NUM_DIV = 5
) (
    input wire clk,
    input wire rst_n,
    output reg clk_div
);

    // Ensure NUM_DIV is odd
    generate
        if (NUM_DIV % 2 == 0) begin : odd_check
            initial begin
                $fatal("NUM_DIV must be an odd number.");
            end
        end
    endgenerate

    reg [($clog2(NUM_DIV)-1):0] cnt1, cnt2;
    reg clk_div1, clk_div2;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            cnt1 <= 0;
            cnt2 <= 0;
            clk_div1 <= 0;
            clk_div2 <= 0;
        end else begin
            // Counter for positive edge
            if (cnt1 == NUM_DIV - 1)
                cnt1 <= 0;
            else
                cnt1 <= cnt1 + 1;

            // Counter for negative edge
            if (cnt2 == NUM_DIV - 1)
                cnt2 <= 0;
            else
                cnt2 <= cnt2 + 1;

            // Toggle clk_div1 on positive edge counter reaching half of NUM_DIV
            if (cnt1 == (NUM_DIV / 2))
                clk_div1 <= ~clk_div1;

            // Toggle clk_div2 on negative edge counter reaching half of NUM_DIV
            if (cnt2 == (NUM_DIV / 2))
                clk_div2 <= ~clk_div2;
        end
    end

    // Final divided clock output
    always @(*) begin
        clk_div = clk_div1 | clk_div2;
    end

endmodule