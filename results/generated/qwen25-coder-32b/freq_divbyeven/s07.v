module freq_diveven #(
    parameter NUM_DIV = 8  // NUM_DIV must be an even number
) (
    input wire clk,        // Input clock signal
    input wire rst_n,      // Active-low reset signal
    output reg clk_div     // Divided clock output signal
);

    // Ensure NUM_DIV is an even number
    generate
        if (NUM_DIV % 2 != 0) begin : gen_error
            initial begin
                $error("NUM_DIV must be an even number.");
                $stop;
            end
        end
    endgenerate

    // Counter to count the clock cycles
    reg [3:0] cnt;  // Assuming NUM_DIV will not exceed 16 (2^4)

    // State machine to handle the frequency division
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            cnt <= 4'b0000;
            clk_div <= 1'b0;
        end else begin
            if (cnt < (NUM_DIV / 2 - 1)) begin
                cnt <= cnt + 1;
            end else begin
                cnt <= 4'b0000;
                clk_div <= ~clk_div;
            end
        end
    end

endmodule