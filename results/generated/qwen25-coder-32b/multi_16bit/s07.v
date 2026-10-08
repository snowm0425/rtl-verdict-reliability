module multi_16bit (
    input wire clk,          // Clock signal
    input wire rst_n,        // Active-low reset signal
    input wire start,        // Start signal to initiate multiplication
    input wire [15:0] ain,   // Multiplicand (a) input
    input wire [15:0] bin,   // Multiplier (b) input
    output reg [31:0] yout,  // Product output
    output reg done          // Multiplication completion flag
);

    reg [4:0] i;           // Shift count register (5 bits to count up to 16)
    reg [31:0] areg;       // Multiplicand register
    reg [31:0] breg;       // Multiplier register
    reg [31:0] yout_r;     // Product register

    // Register for done flag
    reg done_r;

    // Shift and accumulate logic
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            i <= 0;
            areg <= 0;
            breg <= 0;
            yout_r <= 0;
            done_r <= 0;
        end else begin
            if (start && i < 16) begin
                i <= i + 1;
            end else if (!start) begin
                i <= 0;
            end

            if (i == 16) begin
                done_r <= 1;
            end else if (i == 17) begin
                done_r <= 0;
            end

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

    // Output assignment
    assign yout = yout_r;
    assign done = done_r;

endmodule