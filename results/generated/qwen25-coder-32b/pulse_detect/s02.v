module pulse_detect (
    input clk,          // Clock signal
    input rst_n,        // Reset signal (active low)
    input data_in,      // One-bit input signal
    output reg data_out // Output signal indicating the presence of pulses
);

    // Define states for the state machine
    typedef enum reg [1:0] {
        IDLE = 2'b00,
        RISE = 2'b01,
        FALL = 2'b10
    } state_t;

    // Declare the state register
    reg [1:0] state, next_state;

    // State machine logic
    always @(posedge clk or negedge rst_n) begin
        if (~rst_n) begin
            // Reset condition: set state to IDLE and data_out to 0
            state <= IDLE;
            data_out <= 0;
        end else begin
            // Update state with next_state
            state <= next_state;
        end
    end

    // Next state and data_out generation logic
    always @(*) begin
        // Default assignments
        next_state = state;
        data_out = 0;

        // State transition logic
        case (state)
            IDLE: begin
                if (data_in == 1'b1) begin
                    next_state = RISE;
                end
            end
            RISE: begin
                if (data_in == 1'b0) begin
                    next_state = FALL;
                end else if (data_in == 1'b1) begin
                    next_state = RISE; // Stay in RISE if data_in remains high
                end
            end
            FALL: begin
                // When transitioning to FALL, set data_out to 1 indicating the end of a pulse
                data_out = 1;
                next_state = IDLE;
            end
            default: begin
                // Default case, should not reach here
                next_state = IDLE;
            end
        endcase
    end

endmodule