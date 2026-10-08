module signal_generator (
    input wire clk,       // Clock signal used for synchronous operation.
    input wire rst_n,     // Active-low reset signal. Defined as 0 for reset and 1 for reset signal inactive.
    output reg [4:0] wave // 5-bit output waveform signal representing the generated waveform.
);

    // Define a state register
    reg state; // 1-bit state register to control the direction of the waveform (0: increment, 1: decrement)

    // Always block to update the state and wave registers on the positive edge of the clock or negative edge of reset
    always @(posedge clk or negedge rst_n) begin
        if (~rst_n) begin
            // On reset, clear the state and wave registers
            state <= 0;
            wave <= 5'b00000;
        end else begin
            // State and wave generation logic
            case (state)
                0: begin
                    // Increment the wave if state is 0
                    if (wave == 5'b11111) begin // Check if wave has reached 31
                        state <= 1; // Transition to state 1 (decrement)
                    end else begin
                        wave <= wave + 1; // Increment wave by 1
                    end
                end
                1: begin
                    // Decrement the wave if state is 1
                    if (wave == 5'b00000) begin // Check if wave has reached 0
                        state <= 0; // Transition to state 0 (increment)
                    end else begin
                        wave <= wave - 1; // Decrement wave by 1
                    end
                end
                default: begin
                    // Default case (should not occur)
                    state <= 0;
                    wave <= 5'b00000;
                end
            endcase
        end
    end

endmodule