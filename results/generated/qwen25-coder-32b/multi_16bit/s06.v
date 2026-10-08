module multi_16bit (
    input wire clk,          // Chip clock signal
    input wire rst_n,        // Active-low reset signal
    input wire start,        // Chip enable signal to initiate the multiplication operation
    input wire [15:0] ain,   // Input signal representing the multiplicand (a)
    input wire [15:0] bin,   // Input signal representing the multiplier (b)
    output reg [31:0] yout,  // Product output signal
    output reg done          // Chip output flag signal
);

    // Internal registers
    reg [4:0] i;            // Shift count register
    reg [31:0] areg;        // Multiplicand register
    reg [31:0] breg;        // Multiplier register
    reg [31:0] yout_r;      // Product register
    reg done_r;             // Internal multiplication completion flag

    // Clock and reset handling
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            i <= 0;
            areg <= 32'b0;
            breg <= 32'b0;
            yout_r <= 32'b0;
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

            // Perform shift and accumulate operation
            if (start) begin
                if (i == 0) begin
                    areg <= {{16{ain[15]}}, ain};  // Sign-extend multiplicand to 32 bits
                    breg <= {{16{bin[15]}}, bin};  // Sign-extend multiplier to 32 bits
                end else if (i > 0 && i < 17) begin
                    if (areg[i-1]) begin
                        yout_r <= yout_r + (breg << (i-1));
                    end
                end
            end
        end
    end

    // Assign the final product to the output
    assign yout = yout_r;

    // Assign the done flag to the output
    assign done = done_r;

endmodule