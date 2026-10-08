module multi_16bit (
    input wire clk,         // Chip clock signal
    input wire rst_n,       // Active-low reset signal
    input wire start,       // Chip enable signal to initiate multiplication
    input wire [15:0] ain,  // Multiplicand input
    input wire [15:0] bin,  // Multiplier input
    output reg [31:0] yout, // Product output
    output reg done         // Completion flag
);

    reg [3:0] i;          // Shift count register
    reg [15:0] areg;       // Multiplicand register
    reg [15:0] breg;       // Multiplier register
    reg [31:0] yout_r;     // Product register
    reg done_r;            // Internal completion flag

    // Sequential logic for shift count register (i)
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            i <= 0;
        end else if (start && i < 17) begin
            i <= i + 1;
        end else if (!start) begin
            i <= 0;
        end
    end

    // Sequential logic for multiplication completion flag (done_r)
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            done_r <= 0;
        end else if (i == 16) begin
            done_r <= 1;
        end else if (i == 17) begin
            done_r <= 0;
        end
    end

    // Sequential logic for shift and accumulate operation
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            areg <= 0;
            breg <= 0;
            yout_r <= 0;
        end else if (start) begin
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

    // Output assignment
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            yout <= 0;
            done <= 0;
        end else begin
            yout <= yout_r;
            done <= done_r;
        end
    end

endmodule