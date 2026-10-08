module freq_diveven #(
    parameter NUM_DIV = 8  // Must be an even number
) (
    input wire clk,       // Input clock signal
    input wire rst_n,     // Active-low reset signal
    output reg clk_div    // Divided clock output signal
);

    // Ensure NUM_DIV is even
    generate
        if (NUM_DIV % 2 != 0) begin
            $error("NUM_DIV must be an even number.");
        end
    endgenerate

    // Define the counter width based on NUM_DIV
    localparam CNT_WIDTH = $clog2(NUM_DIV);
    reg [CNT_WIDTH-1:0] cnt;  // Counter to track clock cycles

    // Initialize the counter and divided clock on reset
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            cnt <= 0;
            clk_div <= 0;
        end else begin
            if (cnt < (NUM_DIV / 2 - 1)) begin
                cnt <= cnt + 1;
            end else begin
                cnt <= 0;
                clk_div <= ~clk_div;  // Toggle the divided clock output
            end
        end
    end

endmodule