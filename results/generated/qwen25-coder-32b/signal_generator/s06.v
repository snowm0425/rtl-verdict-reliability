module signal_generator (
    input clk,      // Clock signal
    input rst_n,    // Active-low reset signal
    output reg [4:0] wave // 5-bit output waveform signal
);

    // State register to control the waveform generation
    reg state;

    // Initial block to set default values
    initial begin
        state = 0;
        wave = 5'b00000;
    end

    // Always block to update state and wave on posedge clk or negedge rst_n
    always @(posedge clk or negedge rst_n) begin
        if (~rst_n) begin
            // Reset condition
            state <= 0;
            wave <= 5'b00000;
        end else begin
            // State machine to control waveform generation
            case (state)
                0: begin
                    if (wave == 5'b11111) begin
                        state <= 1; // Transition to state 1 when wave reaches 31
                    end else begin
                        wave <= wave + 1; // Increment wave
                    end
                end
                1: begin
                    if (wave == 5'b00000) begin
                        state <= 0; // Transition back to state 0 when wave reaches 0
                    end else begin
                        wave <= wave - 1; // Decrement wave
                    end
                end
                default: begin
                    state <= 0; // Default state
                    wave <= 5'b00000;
                end
            endcase
        end
    end

endmodule