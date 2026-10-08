module freq_diveven #(
    parameter NUM_DIV = 8  // NUM_DIV must be an even number
) (
    input wire clk,       // Input clock signal
    input wire rst_n,     // Active-low reset signal
    output reg clk_div    // Divided clock output signal
);

    // Ensure NUM_DIV is even
    initial begin
        if (NUM_DIV % 2 != 0) begin
            $fatal("NUM_DIV must be an even number");
        end
    end

    // Define a counter to track the number of clock cycles
    reg [3:0] cnt;  // Assuming NUM_DIV <= 16, so 4 bits are sufficient

    // Synchronous logic
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            // Initialize counter and clk_div on reset
            cnt <= 0;
            clk_div <= 0;
        end else begin
            if (cnt < (NUM_DIV / 2 - 1)) begin
                // Increment counter without changing clk_div
                cnt <= cnt + 1;
            end else if (cnt == (NUM_DIV / 2 - 1)) begin
                // Toggle clk_div and reset counter
                cnt <= 0;
                clk_div <= ~clk_div;
            end
        end
    end

endmodule