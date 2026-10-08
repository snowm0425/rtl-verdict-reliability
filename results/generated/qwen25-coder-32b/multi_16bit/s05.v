module multi_16bit (
    input wire clk,         // Clock signal
    input wire rst_n,       // Active-low reset signal
    input wire start,       // Start signal to initiate multiplication
    input wire [15:0] ain,  // Multiplicand (a)
    input wire [15:0] bin,  // Multiplier (b)
    output reg [31:0] yout, // Product output
    output reg done         // Completion flag
);

    // Registers
    reg [3:0] i;            // Shift count register
    reg [15:0] areg;        // Multiplicand register
    reg [15:0] breg;        // Multiplier register
    reg [31:0] yout_r;      // Product register
    reg done_r;             // Completion flag register

    // Sequential logic
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            i <= 0;
            areg <= 0;
            breg <= 0;
            yout_r <= 0;
            done_r <= 0;
        end else begin
            if (start) begin
                if (i < 17) begin
                    i <= i + 1;
                end else begin
                    i <= 0;
                end

                if (i == 0) begin
                    areg <= ain;
                    breg <= bin;
                    yout_r <= 0;
                end else if (i < 17) begin
                    if (areg[i-1]) begin
                        yout_r <= yout_r + (breg << (i-1));
                    end
                end

                if (i == 16) begin
                    done_r <= 1;
                end else if (i == 17) begin
                    done_r <= 0;
                end
            end else begin
                i <= 0;
            end
        end
    end

    // Output assignment
    assign yout = yout_r;
    assign done = done_r;

endmodule