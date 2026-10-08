module multi_16bit (
    input clk,          // Clock signal
    input rst_n,        // Active-low reset signal
    input start,        // Start signal to initiate multiplication
    input [15:0] ain,   // Multiplicand (16 bits)
    input [15:0] bin,   // Multiplier (16 bits)
    output reg [31:0] yout, // Product output (32 bits)
    output reg done     // Multiplication completion flag
);

    // Internal registers
    reg [4:0] i;          // Shift count register (5 bits to count up to 16)
    reg [31:0] areg;      // Register to store multiplicand
    reg [31:0] breg;      // Register to store multiplier
    reg [31:0] yout_r;    // Register to store product
    reg done_r;           // Internal multiplication completion flag

    // Always block for register updates
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            // Reset all registers on reset
            i <= 0;
            areg <= 0;
            breg <= 0;
            yout_r <= 0;
            done_r <= 0;
        end else begin
            // Update shift count register (i)
            if (start && i < 17) begin
                i <= i + 1;
            end else if (!start) begin
                i <= 0;
            end

            // Update multiplication completion flag (done_r)
            if (i == 16) begin
                done_r <= 1;
            end else if (i == 17) begin
                done_r <= 0;
            end

            // Shift and accumulate operation
            if (start) begin
                if (i == 0) begin
                    // Load multiplicand and multiplier into registers
                    areg <= {16'b0, ain};
                    breg <= {16'b0, bin};
                end else if (i > 0 && i < 17) begin
                    // Shift and accumulate if the (i-1)-th bit of areg is high
                    if (areg[i-1]) begin
                        yout_r <= yout_r + (breg << (i-1));
                    end
                end
            end
        end
    end

    // Assign output signals
    assign yout = yout_r;
    assign done = done_r;

endmodule