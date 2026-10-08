module edge_detect (
    input clk,       // Clock signal
    input rst_n,     // Reset signal (active low)
    input a,         // Input signal
    output reg rise, // Output signal indicating a rising edge
    output reg down  // Output signal indicating a falling edge
);

    // Internal signal to store the previous value of 'a'
    reg a_prev;

    // Always block to detect rising and falling edges
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            // Reset condition: Clear both outputs and previous value
            rise <= 0;
            down <= 0;
            a_prev <= 0;
        end else begin
            // Detect rising edge
            if (!a_prev && a) begin
                rise <= 1;
            end else begin
                rise <= 0;
            end

            // Detect falling edge
            if (a_prev && !a) begin
                down <= 1;
            end else begin
                down <= 0;
            end

            // Store the current value of 'a' for the next cycle
            a_prev <= a;
        end
    end

endmodule