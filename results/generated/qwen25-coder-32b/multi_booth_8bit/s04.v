module multi_booth_8bit (
    input clk,
    input reset,
    input [7:0] a,  // Multiplicand
    input [7:0] b,  // Multiplier
    output reg [15:0] p, // Product
    output reg rdy    // Ready signal
);

    reg [15:0] multiplier;
    reg [15:0] multiplicand;
    reg [4:0] ctr;  // 5-bit counter for Radix-4 Booth multiplier

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            // Initialize registers
            multiplier <= {{8{a[7]}}, a};  // Sign extension of a
            multiplicand <= {{8{b[7]}}, b}; // Sign extension of b
            p <= 16'b0;
            ctr <= 5'b0;
            rdy <= 1'b0;
        end else begin
            if (ctr < 16) begin
                // Left shift the multiplicand
                multiplicand <= {multiplicand[14:0], 1'b0};

                // Booth encoding for Radix-4
                case ({multiplier[ctr+1], multiplier[ctr]})
                    2'b01: p <= p + multiplicand;
                    2'b10: p <= p - multiplicand;
                    default: p <= p; // No change for 00 and 11
                endcase

                // Increment the counter
                ctr <= ctr + 1;
            end else begin
                // Multiplication is complete
                rdy <= 1'b1;
            end
        end
    end

endmodule