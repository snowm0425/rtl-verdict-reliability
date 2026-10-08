module signal_generator (
    input wire clk,      // Clock signal used for synchronous operation
    input wire rst_n,    // Active-low reset signal
    output reg [4:0] wave // 5-bit output waveform signal
);

    // State register to control the state of the waveform generation
    reg state;

    // Initialization of state and wave on reset
    always @(posedge clk or negedge rst_n) begin
        if (~rst_n) begin
            state <= 0;   // Clear state on reset
            wave  <= 0;   // Clear wave on reset
        end else begin
            case (state)
                0: begin
                    if (wave == 31) begin
                        state <= 1;   // Transition to state 1 when wave reaches 31
                    end else begin
                        wave <= wave + 1; // Increment wave
                    end
                end
                1: begin
                    if (wave == 0) begin
                        state <= 0;   // Transition back to state 0 when wave reaches 0
                    end else begin
                        wave <= wave - 1; // Decrement wave
                    end
                end
                default: begin
                    state <= 0;   // Default case to ensure state remains 0
                    wave  <= 0;   // Default case to ensure wave remains 0
                end
            endcase
        end
    end

endmodule