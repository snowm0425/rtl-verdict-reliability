module freq_diveven #(
    parameter NUM_DIV = 8  // Must be an even number
) (
    input wire clk,       // Input clock signal
    input wire rst_n,     // Active-low reset signal
    output reg clk_div    // Divided clock output signal
);

    // Ensure NUM_DIV is even
    generate
        if (NUM_DIV % 2 != 0) begin : check_even
            initial begin
                $error("NUM_DIV must be an even number.");
            end
        end
    endgenerate

    // Counter to track clock cycles
    reg [3:0] cnt;

    // Reset and counting logic
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            cnt <= 4'b0;
            clk_div <= 1'b0;
        end else begin
            if (cnt < (NUM_DIV / 2 - 1)) begin
                cnt <= cnt + 1;
            end else begin
                cnt <= 4'b0;
                clk_div <= ~clk_div;
            end
        end
    end

endmodule