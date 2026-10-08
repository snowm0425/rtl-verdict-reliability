module freq_divbyodd #(
    parameter NUM_DIV = 5
) (
    input  clk,
    input  rst_n,
    output reg clk_div
);

    // Two counters to track rising and falling edges
    reg [31:0] cnt1, cnt2;

    // Two intermediate clock signals
    reg clk_div1, clk_div2;

    // Calculate the half division points
    // For odd N, the rising edge happens at floor(N/2) and falling at ceil(N/2)
    // We use: cnt reaches (NUM_DIV - 1) / 2 for one toggle, and NUM_DIV / 2 for the other
    // Let's define:
    //   half1 = (NUM_DIV - 1) / 2  -> this is the integer division, e.g., for 5: (5-1)/2 = 2
    //   half2 = NUM_DIV / 2         -> this is also integer division, e.g., for 5: 5/2 = 2
    // Actually, for odd N:
    //   We want to toggle clk_div1 when cnt1 reaches (NUM_DIV-1)/2
    //   We want to toggle clk_div2 when cnt2 reaches (NUM_DIV-1)/2 + 1 = (NUM_DIV+1)/2
    // Let's use:
    //   cnt1 toggles when cnt1 == (NUM_DIV-1)/2
    //   cnt2 toggles when cnt2 == (NUM_DIV-1)/2 + 1

    wire [31:0] half_val = (NUM_DIV - 1) / 2;
    wire [31:0] half_val_plus1 = (NUM_DIV - 1) / 2 + 1;

    // Counter 1: counts on rising edge of clk
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            cnt1 <= 0;
        end else begin
            if (cnt1 == NUM_DIV - 1)
                cnt1 <= 0;
            else
                cnt1 <= cnt1 + 1;
        end
    end

    // Counter 2: counts on falling edge of clk
    always @(negedge clk or negedge rst_n) begin
        if (!rst_n) begin
            cnt2 <= 0;
        end else begin
            if (cnt2 == NUM_DIV - 1)
                cnt2 <= 0;
            else
                cnt2 <= cnt2 + 1;
        end
    end

    // Toggle clk_div1 when cnt1 reaches half_val
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            clk_div1 <= 1'b0;
        end else if (cnt1 == half_val) begin
            clk_div1 <= ~clk_div1;
        end
    end

    // Toggle clk_div2 when cnt2 reaches half_val_plus1
    always @(negedge clk or negedge rst_n) begin
        if (!rst_n) begin
            clk_div2 <= 1'b0;
        end else if (cnt2 == half_val_plus1) begin
            clk_div2 <= ~clk_div2;
        end
    end

    // Final output is OR of the two divided clocks
    always @(*) begin
        clk_div = clk_div1 | clk_div2;
    end

endmodule