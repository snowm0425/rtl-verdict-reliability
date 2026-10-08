module freq_divbyodd #(
    parameter NUM_DIV = 5 // Must be an odd number
)(
    input clk,          // Input clock signal
    input rst_n,        // Active low reset signal
    output reg clk_div    // Divided clock output
);

    // Ensure NUM_DIV is an odd number
    initial begin
        if (NUM_DIV % 2 == 0) begin
            $fatal("NUM_DIV must be an odd number.");
        end
    end

    reg [($clog2(NUM_DIV)-1):0] cnt1, cnt2; // Counters for tracking clock edges
    reg clk_div1, clk_div2;                  // Clock dividers for rising and falling edges

    // Counter for rising edge
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            cnt1 <= 0;
            clk_div1 <= 0;
        end else begin
            if (cnt1 == (NUM_DIV - 1)) begin
                cnt1 <= 0;
                clk_div1 <= ~clk_div1;
            end else begin
                cnt1 <= cnt1 + 1;
            end
        end
    end

    // Counter for falling edge
    always @(negedge clk or negedge rst_n) begin
        if (!rst_n) begin
            cnt2 <= 0;
            clk_div2 <= 0;
        end else begin
            if (cnt2 == (NUM_DIV - 1)) begin
                cnt2 <= 0;
                clk_div2 <= ~clk_div2;
            end else begin
                cnt2 <= cnt2 + 1;
            end
        end
    end

    // Final divided clock output
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            clk_div <= 0;
        end else begin
            clk_div <= clk_div1 | clk_div2;
        end
    end

endmodule