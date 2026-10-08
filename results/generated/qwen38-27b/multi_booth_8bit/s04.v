module multi_booth_8bit (
    input        clk,
    input        reset,
    input  [7:0] a,
    input  [7:0] b,
    output reg [15:0] p,
    output reg        rdy
);

    reg [15:0] multiplier;
    reg [15:0] multiplicand;
    reg [4:0]  ctr;

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            multiplier   <= {{8{a[7]}}, a};
            multiplicand <= {{8{b[7]}}, b};
            p            <= 16'b0;
            rdy          <= 1'b0;
            ctr          <= 5'd0;
        end else begin
            if (ctr < 5'd16) begin
                // Left-shift multiplicand by 1
                multiplicand <= multiplicand << 1;

                // If current bit of multiplier is 1, add multiplicand to product
                if (multiplier[ctr])
                    p <= p + multiplicand;

                // Increment counter
                ctr <= ctr + 1'b1;
            end else begin
                // Multiplication complete
                rdy <= 1'b1;
            end
        end
    end

endmodule