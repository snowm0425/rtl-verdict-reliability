module signal_generator (
    input clk,        // Clock signal
    input rst_n,      // Active-low reset signal
    output reg [4:0] wave // 5-bit output waveform signal
);

    // Define states for the state machine
    typedef enum logic { 
        INCREMENT = 0, 
        DECREMENT = 1 
    } state_t;

    // State register
    reg state;

    // Initial block to set initial state and wave value
    initial begin
        state = INCREMENT;
        wave = 5'b00000;
    end

    // Always block to handle state transitions and wave generation
    always @(posedge clk or negedge rst_n) begin
        if (~rst_n) begin
            // Reset condition: clear state and wave
            state <= INCREMENT;
            wave <= 5'b00000;
        end else begin
            // State machine logic
            case (state)
                INCREMENT: begin
                    if (wave == 5'b11111) begin
                        // If wave reaches 31, transition to DECREMENT
                        state <= DECREMENT;
                        wave <= wave - 1;
                    end else begin
                        // Otherwise, increment wave
                        wave <= wave + 1;
                    end
                end
                DECREMENT: begin
                    if (wave == 5'b00000) begin
                        // If wave reaches 0, transition to INCREMENT
                        state <= INCREMENT;
                        wave <= wave + 1;
                    end else begin
                        // Otherwise, decrement wave
                        wave <= wave - 1;
                    end
                end
                default: begin
                    // Default case: should not reach here
                    state <= INCREMENT;
                    wave <= 5'b00000;
                end
            endcase
        end
    end

endmodule