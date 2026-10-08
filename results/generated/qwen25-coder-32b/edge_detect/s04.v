module edge_detect (
    input wire clk,      // Clock signal.
    input wire rst_n,    // Reset signal (active low).
    input wire a,        // Input signal.
    output reg rise,     // Output signal indicating a rising edge.
    output reg down      // Output signal indicating a falling edge.
);

    reg a_prev;          // Previous value of input signal a.

    // Always block to update the previous value of 'a' and detect edges.
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            // Asynchronous reset (active low).
            a_prev <= 0;
            rise <= 0;
            down <= 0;
        end else begin
            // Synchronous logic to detect edges.
            a_prev <= a;
            rise <= a & ~a_prev;  // Detect rising edge.
            down <= ~a & a_prev;  // Detect falling edge.
        end
    end

endmodule