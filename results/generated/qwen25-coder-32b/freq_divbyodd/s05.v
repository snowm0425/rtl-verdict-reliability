module freq_divbyodd #(
    parameter NUM_DIV = 5 // Default odd divisor value
)(
    input wire clk,       // Input clock signal
    input wire rst_n,     // Active low reset signal
    output wire clk_div   // Divided clock output
);

    // Ensure NUM_DIV is odd
    generate
        if (NUM_DIV % 2 == 0) begin : gen_error
            initial begin
                $error("NUM_DIV must be an odd number.");
            end
        end
    endgenerate

    // Half of the divisor value
    localparam HALF_DIV = (NUM_DIV + 1) / 2;

    // Counters for rising and falling edges
    reg [$clog2(NUM_DIV)-1:0] cnt1;
    reg [$clog2(NUM_DIV)-1:0] cnt2;

    // Clock dividers for positive and negative edges
    reg clk_div1;
    reg clk_div2;

    // Active low reset logic
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            cnt1 <= 0;
            cnt2 <= 0;
            clk_div1 <= 0;
            clk_div2 <= 0;
        end else begin
            // Rising edge counter
            if (cnt1 == NUM_DIV - 1) begin
                cnt1 <= 0;
            end else begin
                cnt1 <= cnt1 + 1;
            end

            // Falling edge counter
            if (cnt2 == NUM_DIV - 1) begin
                cnt2 <= 0;
            end else begin
                cnt2 <= cnt2 + 1;
            end

            // Toggle clk_div1 on rising edge counter reaching half of NUM_DIV
            if (cnt1 == HALF_DIV - 1) begin
                clk_div1 <= ~clk_div1;
            end

            // Toggle clk_div2 on falling edge counter reaching half of NUM_DIV
            if (cnt2 == HALF_DIV - 1) begin
                clk_div2 <= ~clk_div2;
            end
        end
    end

    // Final divided clock output
    assign clk_div = clk_div1 | clk_div2;

endmodule