module multi_booth_8bit (
    input clk,          // Clock signal
    input reset,        // Reset signal
    input [7:0] a,      // 8-bit multiplicand
    input [7:0] b,      // 8-bit multiplier
    output reg [15:0] p, // 16-bit product
    output reg rdy      // Ready signal
);

    reg [15:0] multiplier;
    reg [15:0] multiplicand;
    reg [4:0] ctr;      // Counter for Booth algorithm (0 to 15)

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            // Initialize registers on reset
            multiplier <= {{8{a[7]}}, a};
            multiplicand <= {{8{b[7]}}, b};
            p <= 16'b0;
            ctr <= 5'b0;
            rdy <= 1'b0;
        end else begin
            if (ctr < 16) begin
                // Booth algorithm processing
                if (multiplier[ctr]) begin
                    p <= p + multiplicand;
                end
                // Left shift the multiplicand
                multiplicand <= {multiplicand[14:0], 1'b0};
                // Increment the counter
                ctr <= ctr + 1;
                // Set ready signal to 0 during multiplication
                rdy <= 1'b0;
            end else begin
                // Multiplication complete
                rdy <= 1'b1;
            end
        end
    end

endmodule