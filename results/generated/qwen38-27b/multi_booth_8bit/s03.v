module multi_booth_8bit (
    input  wire       clk,
    input  wire       reset,
    input  wire [7:0] a,
    input  wire [7:0] b,
    output reg  [15:0] p,
    output reg         rdy
);

    // Internal registers
    reg [15:0] multiplicand;
    reg [15:0] multiplier;
    reg [4:0]  ctr;

    // Initialize counters and outputs on reset
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            multiplicand <= {{8{b[7]}}, b};
            multiplier   <= {{8{a[7]}}, a};
            p            <= 16'd0;
            rdy          <= 1'b0;
            ctr          <= 5'd0;
        end else begin
            if (ctr < 5'd16) begin
                // Left shift multiplicand by 1
                multiplicand <= {multiplicand[14:0], 1'b0};

                // If current bit of multiplier is 1, accumulate multiplicand into product
                if (multiplier[ctr]) begin
                    p <= p + multiplicand;
                end

                // Increment counter
                ctr <= ctr + 5'd1;

                // Set ready when counter reaches 16
                if (ctr == 5'd15) begin
                    rdy <= 1'b1;
                end
            end
        end
    end

endmodule