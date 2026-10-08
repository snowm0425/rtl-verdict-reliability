module freq_divbyodd #(
    parameter NUM_DIV = 5  // Odd number divisor, default is 5
)(
    input wire clk,        // Input clock signal
    input wire rst_n,      // Active low reset signal
    output reg clk_div     // Divided clock output
);

    // Ensure NUM_DIV is an odd number
    initial begin
        if (NUM_DIV % 2 == 0) begin
            $error("NUM_DIV must be an odd number.");
            $finish;
        end
    end

    reg [($clog2(NUM_DIV)-1):0] cnt1, cnt2; // Counters for rising and falling edges
    reg clk_div1, clk_div2; // Clock dividers for positive and negative edges

    // Reset and counting logic
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            cnt1 <= 0;
            cnt2 <= 0;
            clk_div1 <= 0;
            clk_div2 <= 0;
        end else begin
            // Counter for rising edge
            if (cnt1 == NUM_DIV - 1) begin
                cnt1 <= 0;
            end else begin
                cnt1 <= cnt1 + 1;
            end

            // Counter for falling edge
            if (cnt2 == NUM_DIV - 1) begin
                cnt2 <= 0;
            end else begin
                cnt2 <= cnt2 + 1;
            end

            // Toggle clk_div1 on rising edge
            if (cnt1 == (NUM_DIV / 2)) begin
                clk_div1 <= ~clk_div1;
            end

            // Toggle clk_div2 on falling edge
            if (cnt2 == (NUM_DIV / 2)) begin
                clk_div2 <= ~clk_div2;
            end
        end
    end

    // Generate final divided clock output
    always @(*) begin
        clk_div = clk_div1 | clk_div2;
    end

endmodule