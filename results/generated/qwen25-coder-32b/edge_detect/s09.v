module edge_detect (
    input wire clk,       // Clock signal
    input wire rst_n,     // Reset signal (active low)
    input wire a,         // Input signal
    output reg rise,      // Output signal indicating a rising edge
    output reg down       // Output signal indicating a falling edge
);

    reg a_prev;  // Previous value of the input signal 'a'

    // Sequential block to detect edges
    always @(posedge clk or negedge rst_n) begin
        if (~rst_n) begin
            // Reset condition: clear the edge detection signals and previous value
            a_prev <= 0;
            rise <= 0;
            down <= 0;
        end else begin
            // Store the previous value of 'a'
            a_prev <= a;

            // Detect rising and falling edges
            if (a == 1 && a_prev == 0) begin
                rise <= 1;
            end else if (a == 0 && a_prev == 1) begin
                down <= 1;
            end else begin
                rise <= 0;
                down <= 0;
            end
        end
    end
endmodule