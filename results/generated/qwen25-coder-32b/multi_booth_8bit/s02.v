module multi_booth_8bit (
    input clk,
    input reset,
    input [7:0] a,
    input [7:0] b,
    output reg [15:0] p,
    output reg rdy
);

    reg [15:0] multiplier;
    reg [15:0] multiplicand;
    reg [4:0] ctr;

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            // Initialize the registers
            multiplier <= {{8{a[7]}}, a};
            multiplicand <= {{8{b[7]}}, b};
            p <= 16'b0;
            ctr <= 5'b0;
            rdy <= 1'b0;
        end else begin
            if (ctr < 16) begin
                // Booth encoding and multiplication logic
                case ({multiplier[ctr+1], multiplier[ctr]})
                    2'b01: p <= p + multiplicand; // Positive Booth encoding
                    2'b10: p <= p - multiplicand; // Negative Booth encoding
                    default: ; // No action for 00 and 11
                endcase
                
                // Left shift multiplicand by 1
                multiplicand <= multiplicand << 1;
                
                // Increment counter
                ctr <= ctr + 1;
                
                // Set ready signal when multiplication is complete
                if (ctr == 15) begin
                    rdy <= 1'b1;
                end else begin
                    rdy <= 1'b0;
                end
            end
        end
    end

endmodule