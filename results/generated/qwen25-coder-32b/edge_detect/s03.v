module edge_detect (
    input wire clk,      // Clock signal
    input wire rst_n,    // Reset signal (active low)
    input wire a,        // Input signal
    output reg rise,     // Output signal indicating a rising edge
    output reg down      // Output signal indicating a falling edge
);

    reg a_prev;  // Previous value of input signal a

    // Initialize outputs to 0
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            // Asynchronous reset
            a_prev <= 0;
            rise <= 0;
            down <= 0;
        end else begin
            // Sample the previous value of a
            a_prev <= a;
            // Detect rising edge
            if (a && !a_prev) begin
                rise <= 1;
            end else begin
                rise <= 0;
            end
            // Detect falling edge
            if (!a && a_prev) begin
                down <= 1;
            end else begin
                down <= 0;
            end
        end
    end

endmodule