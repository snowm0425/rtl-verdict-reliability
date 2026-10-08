module signal_generator (
    input wire clk,      // Clock signal
    input wire rst_n,    // Active-low reset signal
    output reg [4:0] wave // 5-bit output waveform signal
);

    // State declaration
    reg state; // 1-bit state register (0: increment, 1: decrement)

    // State and wave initialization and update logic
    always @(posedge clk or negedge rst_n) begin
        if (~rst_n) begin
            // Reset condition: clear state and wave registers
            state <= 0;
            wave <= 5'b00000;
        end else begin
            // State and wave update logic
            case (state)
                1'b0: begin // Increment state
                    if (wave == 5'b11111) begin // If wave reaches 31
                        state <= 1'b1; // Change state to decrement
                    end else begin
                        wave <= wave + 1; // Increment wave
                    end
                end
                1'b1: begin // Decrement state
                    if (wave == 5'b00000) begin // If wave reaches 0
                        state <= 1'b0; // Change state to increment
                    end else begin
                        wave <= wave - 1; // Decrement wave
                    end
                end
                default: begin // Default case (should never reach here)
                    state <= 1'b0;
                    wave <= 5'b00000;
                end
            endcase
        end
    end

endmodule