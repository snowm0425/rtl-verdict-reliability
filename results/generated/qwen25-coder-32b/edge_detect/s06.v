module edge_detect (
    input wire clk,       // Clock signal
    input wire rst_n,     // Reset signal (active low)
    input wire a,         // Input signal
    output reg rise,      // Output signal indicating a rising edge
    output reg down       // Output signal indicating a falling edge
);

    reg a_prev; // Previous value of input signal a

    // Synchronize the input signal 'a' with the clock
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            a_prev <= 0; // Reset to 0 when reset is active low
            rise <= 0;
            down <= 0;
        end else begin
            a_prev <= a; // Capture the current value of 'a'

            // Detect rising edge
            if (a_prev == 0 && a == 1) begin
                rise <= 1;
            end else begin
                rise <= 0;
            end

            // Detect falling edge
            if (a_prev == 1 && a == 0) begin
                down <= 1;
            end else begin
                down <= 0;
            end
        end
    end

endmodule