module freq_divbyodd #(
    parameter NUM_DIV = 5 // Must be an odd number
) (
    input wire clk,       // Input clock signal
    input wire rst_n,     // Active low reset signal
    output reg clk_div    // Divided clock output
);

    // Ensure NUM_DIV is odd
    initial begin
        if (NUM_DIV % 2 == 0) begin
            $error("NUM_DIV must be an odd number.");
            $stop;
        end
    end

    // Counters for rising and falling edges
    reg [$clog2(NUM_DIV):0] cnt1, cnt2;

    // Clock dividers for positive and negative edges
    reg clk_div1, clk_div2;

    // Counter for rising edge
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            cnt1 <= 0;
        end else if (cnt1 == NUM_DIV - 1) begin
            cnt1 <= 0;
        end else begin
            cnt1 <= cnt1 + 1;
        end
    end

    // Counter for falling edge
    always @(negedge clk or negedge rst_n) begin
        if (!rst_n) begin
            cnt2 <= 0;
        end else if (cnt2 == NUM_DIV - 1) begin
            cnt2 <= 0;
        end else begin
            cnt2 <= cnt2 + 1;
        end
    end

    // Toggle clk_div1 on rising edge counter reaching half of NUM_DIV
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            clk_div1 <= 0;
        end else if (cnt1 == (NUM_DIV / 2)) begin
            clk_div1 <= ~clk_div1;
        end
    end

    // Toggle clk_div2 on falling edge counter reaching half of NUM_DIV
    always @(negedge clk or negedge rst_n) begin
        if (!rst_n) begin
            clk_div2 <= 0;
        end else if (cnt2 == (NUM_DIV / 2)) begin
            clk_div2 <= ~clk_div2;
        end
    end

    // Final divided clock output is the OR of clk_div1 and clk_div2
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            clk_div <= 0;
        end else begin
            clk_div <= clk_div1 | clk_div2;
        end
    end

endmodule