module counter_12 (
    input  rst_n,        // Reset signal (active low)
    input  clk,          // Clock signal
    input  valid_count,  // Signal to enable counting
    output [3:0] out     // 4-bit output representing the current count value
);

    // Register to store the current count value
    reg [3:0] count;

    // Continuous assignment to the output port
    assign out = count;

    // Always block for synchronous logic
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            // Reset condition: active low reset
            count <= 4'b0000;
        end else if (valid_count) begin
            // Counting condition: increment if valid_count is high
            if (count == 4'd11) begin
                // Wrap around to 0 when count reaches 11 (4'd11)
                count <= 4'b0000;
            end else begin
                // Increment the count
                count <= count + 1;
            end
        end
        // If valid_count is low, the count remains unchanged
    end

endmodule