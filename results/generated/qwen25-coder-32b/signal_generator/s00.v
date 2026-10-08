module signal_generator (
    input wire clk,      // Clock signal
    input wire rst_n,    // Active-low reset signal
    output reg [4:0] wave // 5-bit output waveform signal
);

    reg state; // State register to control the direction of the waveform

    // Always block triggered on the positive edge of the clock or negative edge of reset
    always @(posedge clk or negedge rst_n) begin
        if (~rst_n) begin
            // Reset state and waveform to 0 on reset
            state <= 0;
            wave <= 5'b00000;
        end else begin
            // State machine to control waveform generation
            case (state)
                0: begin
                    if (wave == 5'b11111) begin // If waveform reaches 31
                        state <= 1; // Change state to decrement
                    end else begin
                        wave <= wave + 1; // Increment waveform
                    end
                end
                1: begin
                    if (wave == 5'b00000) begin // If waveform reaches 0
                        state <= 0; // Change state to increment
                    end else begin
                        wave <= wave - 1; // Decrement waveform
                    end
                end
                default: begin
                    state <= 0; // Default state to increment
                    wave <= 5'b00000; // Reset waveform to 0
                end
            endcase
        end
    end

endmodule