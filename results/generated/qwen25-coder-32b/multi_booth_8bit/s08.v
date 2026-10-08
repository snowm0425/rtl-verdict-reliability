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
    reg [3:0] ctr;  // 4-bit counter for Radix-4 Booth encoding

    // Initialize the multiplier and multiplicand on reset
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            // Sign extend the inputs and load into registers
            multiplier <= {{8{a[7]}}, a};
            multiplicand <= {{8{b[7]}}, b};
            ctr <= 4'b0000;  // Reset counter
            p <= 16'b0000000000000000;  // Clear product
            rdy <= 1'b0;  // Not ready yet
        end else begin
            if (ctr < 4'b1000) begin  // Check if counter is less than 8 (since Radix-4 Booth needs 8 iterations)
                // Perform Radix-4 Booth multiplication
                case (multiplier[1:0])  // Check the current two bits of the multiplier
                    2'b00: begin
                        // Do nothing, no addition
                    end
                    2'b01: begin
                        p <= p + multiplicand;  // Add multiplicand
                    end
                    2'b10: begin
                        p <= p - multiplicand;  // Subtract multiplicand
                    end
                    2'b11: begin
                        // Do nothing, no addition
                    end
                endcase

                // Left shift the multiplicand by 2 (Radix-4 Booth encoding)
                multiplicand <= multiplicand << 2;

                // Increment the counter
                ctr <= ctr + 1;
            end else begin
                // Multiplication is complete
                rdy <= 1'b1;
            end
        end
    end

endmodule