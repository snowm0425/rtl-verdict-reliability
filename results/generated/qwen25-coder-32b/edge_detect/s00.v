module edge_detect (
    input wire clk,       // Clock signal
    input wire rst_n,     // Reset signal (active low)
    input wire a,         // Input signal
    output reg rise,      // Output signal indicating a rising edge
    output reg down       // Output signal indicating a falling edge
);

reg a_dff;  // DFF to store the previous value of 'a'

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        a_dff <= 0;  // Reset the DFF to 0 on reset
        rise <= 0;   // Reset the rise signal
        down <= 0;   // Reset the down signal
    end else begin
        // Detect rising edge
        if (a && !a_dff) begin
            rise <= 1;  // Set rise to 1 if a rising edge is detected
        end else begin
            rise <= 0;  // Otherwise, set rise to 0
        end

        // Detect falling edge
        if (!a && a_dff) begin
            down <= 1;  // Set down to 1 if a falling edge is detected
        end else begin
            down <= 0;  // Otherwise, set down to 0
        end

        // Update the DFF with the current value of 'a'
        a_dff <= a;
    end
end

endmodule