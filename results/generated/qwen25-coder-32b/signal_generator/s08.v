module signal_generator (
    input wire clk,      // Clock signal
    input wire rst_n,    // Active-low reset signal
    output reg [4:0] wave // 5-bit output waveform signal
);

    reg state; // State register to control waveform generation

    // Initialize wave and state on reset
    always @(posedge clk or negedge rst_n) begin
        if (~rst_n) begin
            wave <= 5'b00000; // Clear wave to 0
            state <= 1'b0;     // Clear state to 0
        end else begin
            case (state)
                1'b0: begin
                    if (wave == 5'b11111) begin // If wave reaches 31
                        state <= 1'b1;          // Transition to state 1
                    end else begin
                        wave <= wave + 1;       // Increment wave
                    end
                end
                1'b1: begin
                    if (wave == 5'b00000) begin // If wave reaches 0
                        state <= 1'b0;          // Transition to state 0
                    end else begin
                        wave <= wave - 1;       // Decrement wave
                    end
                end
            endcase
        end
    end

endmodule