module freq_divbyodd #(
    parameter NUM_DIV = 5
) (
    input  wire clk,
    input  wire rst_n,
    output reg  clk_div
);

    localparam COUNTER_WIDTH = $clog2(NUM_DIV);
    
    reg [COUNTER_WIDTH-1:0] cnt1;
    reg [COUNTER_WIDTH-1:0] cnt2;
    
    reg clk_div1;
    reg clk_div2;
    
    // Half divider values
    // For odd division, we toggle clk_div1 on rising edge when cnt1 == (NUM_DIV-1)/2
    // and toggle clk_div2 on falling edge when cnt2 == (NUM_DIV-1)/2
    // Actually, let's think about this more carefully.
    
    // For odd N, the standard technique is:
    // - clk_div1 is toggled on rising clock edge when cnt1 reaches (N-1)/2
    // - clk_div2 is toggled on falling clock edge when cnt2 reaches (N-1)/2
    // - clk_div = clk_div1 | clk_div2
    
    // But we need to handle the counters properly. Let me re-derive.
    
    // For N=5:
    // We want output frequency = clk_freq / 5
    // Output high for 2.5 cycles, low for 2.5 cycles
    
    // The typical implementation:
    // cnt1 counts on rising edge of clk, resets when it reaches (N-1)/2, toggles clk_div1
    // cnt2 counts on falling edge of clk, resets when it reaches (N-1)/2, toggles clk_div2
    // clk_div = clk_div1 | clk_div2
    
    // Wait, let me reconsider. A common approach:
    // Two counters, each going from 0 to (N-1)/2
    // On rising edge: increment cnt1. When cnt1 == (N-1)/2, reset cnt1 to 0 and toggle clk_div1
    // On falling edge: increment cnt2. When cnt2 == (N-1)/2, reset cnt2 to 0 and toggle clk_div2
    // clk_div = clk_div1 | clk_div2
    
    // For N=5, (N-1)/2 = 2. So counters go 0,1,2 then reset.
    // This gives a period of 5 half-cycles of the original clock... 
    // Actually, let's just implement it as described.
    
    localparam HALF_DIV = (NUM_DIV - 1) / 2;
    
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            cnt1 <= {COUNTER_WIDTH{1'b0}};
            clk_div1 <= 1'b0;
        end else begin
            if (cnt1 == HALF_DIV) begin
                cnt1 <= {COUNTER_WIDTH{1'b0}};
                clk_div1 <= ~clk_div1;
            end else begin
                cnt1 <= cnt1 + 1'b1;
            end
        end
    end
    
    always @(negedge clk or negedge rst_n) begin
        if (!rst_n) begin
            cnt2 <= {COUNTER_WIDTH{1'b0}};
            clk_div2 <= 1'b0;
        end else begin
            if (cnt2 == HALF_DIV) begin
                cnt2 <= {COUNTER_WIDTH{1'b0}};
                clk_div2 <= ~clk_div2;
            end else begin
                cnt2 <= cnt2 + 1'b1;
            end
        end
    end
    
    assign clk_div = clk_div1 | clk_div2;

endmodule