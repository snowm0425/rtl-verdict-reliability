module edge_detect (
    input wire clk,       // Clock signal
    input wire rst_n,     // Reset signal (active low)
    input wire a,         // Input signal

    output reg rise,      // Output signal indicating a rising edge
    output reg down       // Output signal indicating a falling edge
);

    reg a_prev;  // Previous value of signal 'a'

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            a_prev <= 0;  // Reset the previous value of 'a' to 0
            rise <= 0;    // Reset the rise signal to 0
            down <= 0;    // Reset the down signal to 0
        end else begin
            // Store the current value of 'a' into 'a_prev'
            a_prev <= a;

            // Detect rising edge
            if (a && !a_prev) begin
                rise <= 1;  // Set rise signal to 1
            end else begin
                rise <= 0;  // Reset rise signal to 0
            end

            // Detect falling edge
            if (!a && a_prev) begin
                down <= 1;  // Set down signal to 1
            end else begin
                down <= 0;  // Reset down signal to 0
            end
        end
    end

endmodule