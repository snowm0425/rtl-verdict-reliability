module signal_generator (
    input clk,          // Clock signal
    input rst_n,        // Active-low reset signal
    output reg [4:0] wave // 5-bit output waveform signal
);

    // State register to control the direction of the waveform generation
    reg state; // 1-bit state register (0 for increment, 1 for decrement)

    // Always block for state and waveform generation
    always @(posedge clk or negedge rst_n) begin
        if (~rst_n) begin
            // Reset condition: clear state and wave registers
            state <= 0;
            wave <= 0;
        end else begin
            // State machine to control waveform generation
            case (state)
                0: begin
                    // Increment state
                    if (wave == 31) begin
                        state <= 1; // Transition to decrement state
                    end else begin
                        wave <= wave + 1; // Increment wave
                    end
                end
                1: begin
                    // Decrement state
                    if (wave == 0) begin
                        state <= 0; // Transition to increment state
                    end else begin
                        wave <= wave - 1; // Decrement wave
                    end
                end
                default: begin
                    // Default case: should never reach here
                    state <= 0;
                    wave <= 0;
                end
            endcase
        end
    end

endmodule