module edge_detect (
    input wire clk,      // Clock signal
    input wire rst_n,    // Reset signal (active low)
    input wire a,        // Input signal
    output reg rise,     // Output signal indicating a rising edge
    output reg down      // Output signal indicating a falling edge
);

    reg a_prev;  // Previous value of input signal a

    // Synchronous block to detect edges
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            // Active low reset
            a_prev <= 0;
            rise   <= 0;
            down   <= 0;
        end else begin
            // Detect rising and falling edges
            a_prev <= a;
            if (a && !a_prev) begin
                // Rising edge detected
                rise <= 1;
                down <= 0;
            end else if (!a && a_prev) begin
                // Falling edge detected
                rise <= 0;
                down <= 1;
            end else begin
                // No edge detected
                rise <= 0;
                down <= 0;
            end
        end
    end

endmodule