module multi_booth_8bit (
    input clk,          // Clock signal
    input reset,        // Reset signal
    input [7:0] a,      // 8-bit multiplicand
    input [7:0] b,      // 8-bit multiplier
    output reg [15:0] p, // 16-bit product
    output reg rdy      // Ready signal
);

    // Internal registers
    reg [15:0] multiplier; // Extended multiplicand
    reg [15:0] multiplicand; // Extended multiplier
    reg [4:0] ctr;           // Counter for Booth algorithm

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            // Initialize the multiplier and multiplicand with sign extension
            multiplier <= {{8{a[7]}}, a};
            multiplicand <= {{8{b[7]}}, b};
            p <= 16'b0; // Clear product
            ctr <= 5'b0; // Clear counter
            rdy <= 1'b0; // Clear ready signal
        end else begin
            if (ctr < 5'd16) begin
                // Booth algorithm implementation
                case ({multiplier[ctr+1], multiplier[ctr]})
                    2'b01: begin
                        // Add multiplicand to product (positive Booth encoding)
                        p <= p + multiplicand;
                    end
                    2'b10: begin
                        // Subtract multiplicand from product (negative Booth encoding)
                        p <= p - multiplicand;
                    end
                    2'b11, 2'b00: begin
                        // No operation for these cases
                    end
                endcase

                // Left shift the multiplicand by 1
                multiplicand <= {multiplicand[14:0], 1'b0};

                // Increment the counter
                ctr <= ctr + 1;

                // Clear ready signal
                rdy <= 1'b0;
            end else begin
                // Set the ready signal once the multiplication is complete
                rdy <= 1'b1;
            end
        end
    end

endmodule