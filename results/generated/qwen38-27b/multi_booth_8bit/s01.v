module multi_booth_8bit (
    input  wire       clk,
    input  wire       reset,
    input  wire [7:0] a,
    input  wire [7:0] b,
    output reg  [15:0] p,
    output reg         rdy
);

    reg [15:0] multiplier;
    reg [15:0] multiplicand;
    reg [4:0]  ctr;

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            multiplier <= {{8{a[7]}}, a};
            multiplicand <= {{8{b[7]}}, b};
            p <= 16'd0;
            rdy <= 1'b0;
            ctr <= 5'd0;
        end else begin
            if (rdy) begin
                // Wait for reset or new operation? The spec says rdy stays 1 until reset.
                // But typically, we might want to allow re-trigger. However, spec says
                // "ready signal (rdy) is set to 1 to indicate the completion".
                // Let's keep rdy high until reset.
                rdy <= 1'b1;
                // Keep previous values or hold? Spec doesn't explicitly say to clear on rdy.
                // We'll just hold the last product and state.
                ctr <= ctr;
                p <= p;
                multiplier <= multiplier;
                multiplicand <= multiplicand;
            end else begin
                if (ctr < 5'd16) begin
                    // Left shift multiplicand by 1
                    multiplicand <= {multiplicand[14:0], 1'b0};
                    
                    // If current bit of multiplier is 1, add multiplicand to product
                    if (multiplier[ctr]) begin
                        p <= p + multiplicand;
                    end else begin
                        p <= p;
                    end
                    
                    // Increment counter
                    ctr <= ctr + 5'd1;
                end else begin
                    // ctr reached 16, set ready
                    rdy <= 1'b1;
                end
            end
        end
    end

endmodule