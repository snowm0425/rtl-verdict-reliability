module signal_generator (
    input wire clk,      // Clock signal
    input wire rst_n,    // Active-low reset signal
    output reg [4:0] wave // 5-bit output waveform signal
);

    // State declaration
    reg state; // 1-bit state register to control waveform direction

    // Initialize state and wave registers on reset
    always @(posedge clk or negedge rst_n) begin
        if (~rst_n) begin
            state <= 0;   // Start in state 0 (incrementing)
            wave  <= 5'b0; // Start at 0
        end else begin
            case (state)
                1'b0: begin
                    if (wave == 5'd31) begin
                        state <= 1'b1; // Transition to state 1 (decrementing)
                    end else begin
                        wave <= wave + 1; // Increment waveform
                    end
                end
                1'b1: begin
                    if (wave == 5'd0) begin
                        state <= 1'b0; // Transition to state 0 (incrementing)
                    end else begin
                        wave <= wave - 1; // Decrement waveform
                    end
                end
                default: begin
                    state <= 1'b0; // Default to state 0
                    wave  <= 5'b0; // Reset waveform
                end
            endcase
        end
    end

endmodule