module multi_booth_8bit (
    input clk,
    input reset,
    input [7:0] a,
    input [7:0] b,
    output reg [15:0] p,
    output reg rdy
);

    // Internal registers
    reg [15:0] multiplier;
    reg [15:0] multiplicand;
    reg [4:0] ctr;  // 5-bit counter for 8-bit * 8-bit multiplication (16 iterations)

    // Initialize multiplier and multiplicand on reset
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            multiplier <= {{8{a[7]}}, a};  // Sign-extend the multiplicand
            multiplicand <= {{8{b[7]}}, b}; // Sign-extend the multiplier
            p <= 16'b0;
            ctr <= 5'b0;
            rdy <= 1'b0;
        end else begin
            if (ctr < 16) begin
                // Booth's algorithm implementation
                // Check the current bit of the multiplier (multiplier[ctr])
                if (multiplier[ctr] == 1'b1) begin
                    p <= p + multiplicand;
                end

                // Shift the multiplicand left by 1 for the next iteration
                multiplicand <= {multiplicand[14:0], 1'b0};

                // Increment the counter
                ctr <= ctr + 1;
            end else begin
                // Set the ready signal when multiplication is complete
                rdy <= 1'b1;
            end
        end
    end

endmodule