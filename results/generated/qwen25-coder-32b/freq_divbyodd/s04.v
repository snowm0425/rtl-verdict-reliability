module freq_divbyodd #(
    parameter NUM_DIV = 5  // Ensure NUM_DIV is an odd number
)(
    input wire clk,
    input wire rst_n,
    output reg clk_div
);

// Ensure NUM_DIV is an odd number
generate
    if (NUM_DIV % 2 == 0) begin : check_odd
        $error("NUM_DIV must be an odd number.");
    end
endgenerate

reg [31:0] cnt1;  // Counter for rising edge
reg [31:0] cnt2;  // Counter for falling edge
reg clk_div1;       // Clock divider for rising edge
reg clk_div2;       // Clock divider for falling edge

// Half of the divisor for edge toggling
localparam HALF_DIV = (NUM_DIV / 2) + 1;

// Reset and counter logic
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        cnt1 <= 0;
        cnt2 <= 0;
        clk_div1 <= 0;
        clk_div2 <= 0;
        clk_div <= 0;
    end else begin
        // Counting on rising edge
        if (clk) begin
            if (cnt1 == NUM_DIV - 1) begin
                cnt1 <= 0;
                clk_div1 <= ~clk_div1;
            end else begin
                cnt1 <= cnt1 + 1;
            end
        end else begin
            // Counting on falling edge
            if (cnt2 == NUM_DIV - 1) begin
                cnt2 <= 0;
                clk_div2 <= ~clk_div2;
            end else begin
                cnt2 <= cnt2 + 1;
            end
        end

        // Final divided clock output
        clk_div <= clk_div1 | clk_div2;
    end
end

endmodule