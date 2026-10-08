module edge_detect (
    input wire clk,       // Clock signal
    input wire rst_n,     // Reset signal (active low)
    input wire a,         // Input signal
    output reg rise,      // Output signal indicating a rising edge
    output reg down       // Output signal indicating a falling edge
);

    reg a_reg;  // Registered version of the input signal

    // Synchronize the input signal 'a' with the clock
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            a_reg <= 0;
            rise <= 0;
            down <= 0;
        end else begin
            a_reg <= a;
            // Detect rising edge
            rise <= (a && !a_reg);
            // Detect falling edge
            down <= (!a && a_reg);
        end
    end

endmodule