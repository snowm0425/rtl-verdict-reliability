module signal_generator (
    input clk,        // Clock signal
    input rst_n,      // Active-low reset signal
    output reg [4:0] wave // 5-bit output waveform signal
);

// State register to control the direction of the waveform (0: increment, 1: decrement)
reg state;

always @(posedge clk or negedge rst_n) begin
    if (~rst_n) begin
        // Reset state and wave to 0 on reset
        state <= 0;
        wave <= 5'b00000;
    end else begin
        // State machine to control the waveform generation
        case (state)
            0: begin
                // Increment the waveform
                if (wave == 5'd31) begin
                    // If waveform reaches 31, transition to state 1 (decrement)
                    state <= 1;
                end else begin
                    wave <= wave + 1;
                end
            end
            1: begin
                // Decrement the waveform
                if (wave == 5'd0) begin
                    // If waveform reaches 0, transition to state 0 (increment)
                    state <= 0;
                end else begin
                    wave <= wave - 1;
                end
            end
            default: begin
                // Default state (should never reach here)
                state <= 0;
                wave <= 5'b00000;
            end
        endcase
    end
end

endmodule