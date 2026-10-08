module edge_detect (
    input clk,       // Clock signal
    input rst_n,     // Reset signal (active low)
    input a,         // Input signal

    output reg rise, // Output signal indicating a rising edge
    output reg down  // Output signal indicating a falling edge
);

    reg a_prev; // Previous value of the input signal 'a'

    // Sequential block to detect edges
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            // Reset both outputs and the previous value of 'a'
            rise <= 0;
            down <= 0;
            a_prev <= 0;
        end else begin
            // Detect rising edge
            if (a && !a_prev) begin
                rise <= 1;
                down <= 0;
            end
            // Detect falling edge
            else if (!a && a_prev) begin
                rise <= 0;
                down <= 1;
            end
            // No edge detected
            else begin
                rise <= 0;
                down <= 0;
            end

            // Update the previous value of 'a'
            a_prev <= a;
        end
    end

endmodule