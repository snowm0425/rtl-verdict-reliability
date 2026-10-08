module multi_16bit (
    input wire clk,
    input wire rst_n,
    input wire start,
    input wire [15:0] ain,
    input wire [15:0] bin,
    output reg [31:0] yout,
    output reg done
);

    // Internal registers
    reg [3:0] i; // Shift count register (4 bits to hold values from 0 to 17)
    reg [15:0] areg; // Multiplicand register
    reg [15:0] breg; // Multiplier register
    reg [31:0] yout_r; // Product register

    // Register to hold the done signal
    reg done_r;

    // Shift and accumulate process
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            // Reset condition
            i <= 0;
            areg <= 16'b0;
            breg <= 16'b0;
            yout_r <= 32'b0;
            done_r <= 0;
        end else begin
            if (start && i < 17) begin
                // Increment shift count register
                i <= i + 1;
            end else if (!start) begin
                // Reset shift count register if start is inactive
                i <= 0;
            end

            if (i == 16) begin
                // Set done flag when multiplication is complete
                done_r <= 1;
            end else if (i == 17) begin
                // Reset done flag after completion
                done_r <= 0;
            end

            if (start) begin
                if (i == 0) begin
                    // Load multiplicand and multiplier into registers
                    areg <= ain;
                    breg <= bin;
                end else if (i > 0 && i < 17) begin
                    // Shift and accumulate operation
                    if (areg[i-1]) begin
                        yout_r <= yout_r + (breg << (i-1));
                    end
                end
            end
        end
    end

    // Output assignment
    assign yout = yout_r;
    assign done = done_r;

endmodule