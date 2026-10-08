module multi_16bit (
    input wire clk,          // Chip clock signal
    input wire rst_n,        // Active-low reset signal
    input wire start,        // Chip enable signal to initiate the multiplication operation
    input wire [15:0] ain,   // Input signal representing the multiplicand (a)
    input wire [15:0] bin,   // Input signal representing the multiplier (b)
    output reg [31:0] yout,  // Product output signal
    output reg done          // Chip output flag signal
);

    reg [4:0] i;            // Shift count register
    reg [15:0] areg;       // Register to store multiplicand
    reg [15:0] breg;       // Register to store multiplier
    reg [31:0] yout_r;     // Register to store product
    reg done_r;             // Internal register for the done signal

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            i <= 0;
            areg <= 16'b0;
            breg <= 16'b0;
            yout_r <= 32'b0;
            done_r <= 0;
        end else begin
            if (start && i < 17) begin
                i <= i + 1;
            end else if (!start) begin
                i <= 0;
            end

            if (i == 16) begin
                done_r <= 1;
            end else if (i == 17) begin
                done_r <= 0;
            end

            if (start) begin
                if (i == 0) begin
                    areg <= ain;
                    breg <= bin;
                end else if (i > 0 && i < 17) begin
                    if (areg[i-1]) begin
                        yout_r <= yout_r + (breg << (i-1));
                    end
                end
            end
        end
    end

    assign yout = yout_r;
    assign done = done_r;

endmodule