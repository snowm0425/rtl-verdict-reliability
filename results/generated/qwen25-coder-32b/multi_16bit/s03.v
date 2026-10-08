module multi_16bit (
    input clk,          // Chip clock signal.
    input rst_n,        // Active-low reset signal.
    input start,        // Chip enable signal to initiate the multiplication operation.
    input [15:0] ain,   // Input signal representing the multiplicand (a) with a data width of 16 bits.
    input [15:0] bin,   // Input signal representing the multiplier (b) with a data width of 16 bits.
    output reg [31:0] yout, // Product output signal with a data width of 32 bits.
    output reg done     // Chip output flag signal indicating the completion of the multiplication operation.
);

    // Internal registers
    reg [4:0] i;          // Shift count register (5 bits to count up to 16)
    reg [15:0] areg;      // Multiplicand register
    reg [15:0] breg;      // Multiplier register
    reg [31:0] yout_r;    // Product register
    reg done_r;           // Internal multiplication completion flag

    // Sequential logic
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            i <= 0;
            areg <= 16'b0;
            breg <= 16'b0;
            yout_r <= 32'b0;
            done_r <= 0;
        end else begin
            if (start) begin
                if (i < 17) begin
                    i <= i + 1;
                end else begin
                    i <= 0;
                end
            end else begin
                i <= 0;
            end

            // Multiplication completion flag
            if (i == 16) begin
                done_r <= 1;
            end else if (i == 17) begin
                done_r <= 0;
            end

            // Shift and accumulate operation
            if (i == 0) begin
                areg <= ain;
                breg <= bin;
                yout_r <= 32'b0;
            end else if (i > 0 && i < 17) begin
                if (areg[i-1] == 1) begin
                    yout_r <= yout_r + (breg << (i-1));
                end
            end
        end
    end

    // Output assignment
    assign yout = yout_r;
    assign done = done_r;

endmodule