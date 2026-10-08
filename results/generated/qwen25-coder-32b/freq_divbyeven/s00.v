module freq_diveven #(
    parameter NUM_DIV = 8  // Division factor, must be an even number
)(
    input wire clk,       // Input clock signal
    input wire rst_n,     // Active-low reset signal
    output reg clk_div    // Divided clock output signal
);

    // Ensure NUM_DIV is an even number
    initial begin
        if (NUM_DIV % 2 != 0) begin
            $error("NUM_DIV must be an even number.");
        end
    end

    // Counter to track the number of clock cycles
    reg [3:0] cnt;  // Assuming NUM_DIV <= 16, 4-bit counter is sufficient

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            // Reset the counter and the divided clock signal
            cnt <= 4'b0000;
            clk_div <= 1'b0;
        end else begin
            // Check if the counter has reached the specified limit
            if (cnt < (NUM_DIV / 2) - 1) begin
                // Increment the counter without changing the divided clock output
                cnt <= cnt + 1;
            end else begin
                // Reset the counter and toggle the divided clock output
                cnt <= 4'b0000;
                clk_div <= ~clk_div;
            end
        end
    end

endmodule