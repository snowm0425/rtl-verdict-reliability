module multi_booth_8bit (
    input wire clk,
    input wire reset,
    input wire [7:0] a,
    input wire [7:0] b,
    output reg [15:0] p,
    output reg rdy
);

    // Internal registers
    reg [15:0] multiplier;
    reg [15:0] multiplicand;
    reg [4:0] ctr;

    // Booth multiplier process
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            // Initialize registers on reset
            multiplier <= {{8{a[7]}}, a};
            multiplicand <= {{8{b[7]}}, b};
            p <= 16'b0;
            ctr <= 5'b0;
            rdy <= 1'b0;
        end else begin
            // Normal operation
            if (ctr < 5'd16) begin
                // Shift multiplicand left by 1
                multiplicand <= multiplicand << 1;

                // Booth encoding and accumulation
                case ({multiplier[ctr + 1], multiplier[ctr]})
                    2'b01: p <= p + multiplicand; // Positive Booth encoding
                    2'b10: p <= p - multiplicand; // Negative Booth encoding
                    default: ; // No action for 00 and 11
                endcase

                // Increment counter
                ctr <= ctr + 1;
            end else begin
                // Multiplication complete
                rdy <= 1'b1;
            end
        end
    end

endmodule