module freq_diveven #(
    parameter NUM_DIV = 8  // Ensure NUM_DIV is an even number
)(
    input wire clk,       // Input clock signal
    input wire rst_n,     // Active-low reset signal
    output reg clk_div    // Divided clock output signal
);

    // Ensure NUM_DIV is even
    generate
        if (NUM_DIV % 2 != 0) begin
            initial begin
                $fatal("NUM_DIV must be an even number");
            end
        end
    endgenerate

    reg [3:0] cnt;  // 4-bit counter

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            cnt <= 4'b0;      // Reset counter to 0
            clk_div <= 1'b0;  // Initialize divided clock to 0
        end else begin
            if (cnt < (NUM_DIV / 2 - 1)) begin
                cnt <= cnt + 1;  // Increment counter
            end else begin
                cnt <= 4'b0;      // Reset counter
                clk_div <= ~clk_div;  // Toggle the divided clock
            end
        end
    end

endmodule