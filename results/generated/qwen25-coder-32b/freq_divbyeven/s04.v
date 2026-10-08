module freq_diveven #(
    parameter NUM_DIV = 8  // NUM_DIV must be an even number
) (
    input clk,       // Input clock signal
    input rst_n,     // Active-low reset signal
    output reg clk_div // Divided clock output signal
);

    // Ensure NUM_DIV is even
    initial begin
        if (NUM_DIV % 2 != 0) begin
            $fatal("NUM_DIV must be an even number.");
        end
    end

    // Define the counter
    reg [3:0] cnt;

    // Counter and clk_div logic
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            // Reset condition
            cnt <= 4'b0000;
            clk_div <= 1'b0;
        end else begin
            // Normal operation
            if (cnt < (NUM_DIV / 2 - 1)) begin
                // Increment the counter without changing clk_div
                cnt <= cnt + 1;
            end else if (cnt == (NUM_DIV / 2 - 1)) begin
                // Toggle clk_div and reset counter
                cnt <= 4'b0000;
                clk_div <= ~clk_div;
            end else begin
                // This condition should not occur due to the logic above
                cnt <= 4'b0000;
            end
        end
    end

endmodule