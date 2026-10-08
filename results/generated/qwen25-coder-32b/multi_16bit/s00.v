module multi_16bit (
    input clk,          // Chip clock signal
    input rst_n,        // Active-low reset signal
    input start,        // Chip enable signal to initiate the multiplication operation
    input [15:0] ain,   // Input signal representing the multiplicand (a) with a data width of 16 bits
    input [15:0] bin,   // Input signal representing the multiplier (b) with a data width of 16 bits
    output reg [31:0] yout, // Product output signal with a data width of 32 bits
    output reg done     // Chip output flag signal. Defined as 1 indicates the completion of the multiplication operation
);

    // Internal registers
    reg [4:0] i;        // Shift count register
    reg [15:0] areg;    // Multiplicand register
    reg [15:0] breg;    // Multiplier register
    reg [31:0] yout_r;  // Product register
    reg done_r;         // Multiplication completion flag

    // Shift and accumulate operation
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            // Reset condition
            i <= 0;
            areg <= 16'b0;
            breg <= 16'b0;
            yout_r <= 32'b0;
            done_r <= 0;
        end else begin
            // Normal operation
            if (start) begin
                if (i == 0) begin
                    // Load the multiplicand and multiplier into their respective registers
                    areg <= ain;
                    breg <= bin;
                end

                if (i < 17) begin
                    // Shift count register increment
                    i <= i + 1;

                    // Perform shift and accumulate operation
                    if (areg[i-1]) begin
                        yout_r <= yout_r + (breg << (i-1));
                    end
                end
            end else begin
                // Reset the shift count register if start is inactive
                i <= 0;
            end

            // Update the multiplication completion flag
            if (i == 16) begin
                done_r <= 1;
            end else if (i == 17) begin
                done_r <= 0;
            end
        end
    end

    // Assign the final product output
    assign yout = yout_r;

    // Assign the done signal
    assign done = done_r;

endmodule