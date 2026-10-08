module multi_booth_8bit (
    input clk,
    input reset,
    input [7:0] a,    // multiplicand
    input [7:0] b,    // multiplier
    output reg [15:0] p, // product
    output reg rdy    // ready signal
);

    reg [15:0] multiplier;
    reg [15:0] multiplicand;
    reg [4:0] ctr;  // 5-bit counter for 8-bit multiplication (0 to 15)

    // Initialize registers on reset
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            multiplier <= {{8{a[7]}}, a};
            multiplicand <= {{8{b[7]}}, b};
            p <= 16'b0;
            ctr <= 5'b0;
            rdy <= 1'b0;
        end else begin
            if (ctr < 16) begin
                // Booth encoding and accumulation
                if (multiplier[ctr] == 1'b1) begin
                    p <= p + multiplicand;
                end
                // Left shift the multiplicand for the next bit
                multiplicand <= {multiplicand[14:0], 1'b0};
                // Increment the counter
                ctr <= ctr + 1;
                // Set ready signal when the counter reaches 16
                if (ctr == 15) begin
                    rdy <= 1'b1;
                end
            end
        end
    end

endmodule