module pulse_detect (
    input clk,        // Clock signal
    input rst_n,      // Reset signal (active low)
    input data_in,    // One-bit input signal
    output data_out   // Output signal indicating the presence of pulses
);

    // Define states for the state machine
    typedef enum logic [1:0] {
        IDLE,
        RISE,
        FALL
    } state_t;

    state_t state, next_state;

    // Register to hold the output
    logic data_out_reg;

    // State machine to detect pulses
    always_ff @(posedge clk or negedge rst_n) begin
        if (~rst_n) begin
            state <= IDLE;
            data_out_reg <= 0;
        end else begin
            state <= next_state;
        end
    end

    // Next state and output logic
    always_comb begin
        next_state = state;
        data_out_reg = 0;

        case (state)
            IDLE: begin
                if (data_in == 1) begin
                    next_state = RISE;
                end
            end

            RISE: begin
                if (data_in == 0) begin
                    next_state = FALL;
                end
            end

            FALL: begin
                data_out_reg = 1;  // Indicate the end of a pulse
                next_state = IDLE;
            end

            default: begin
                next_state = IDLE;
            end
        endcase
    end

    // Output assignment
    assign data_out = data_out_reg;

endmodule