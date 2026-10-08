module sequence_detector (
    input clk,          // Clock signal
    input reset_n,      // Active-low reset signal
    input data_in,      // 1-bit binary input signal
    output reg sequence_detected  // Output signal indicating sequence detection
);

    // Define the states of the FSM
    typedef enum reg [1:0] {
        IDLE = 2'b00,
        S1 = 2'b01,
        S2 = 2'b10,
        S3 = 2'b11
    } state_t;

    // State variables
    state_t current_state, next_state;

    // State transition logic
    always @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            current_state <= IDLE;
            sequence_detected <= 0;
        end else begin
            current_state <= next_state;
            sequence_detected <= (current_state == S3 && data_in == 1);
        end
    end

    // Next state logic and output logic
    always @(*) begin
        next_state = current_state;  // Default: stay in the current state

        case (current_state)
            IDLE: begin
                if (data_in == 1)
                    next_state = S1;
            end
            S1: begin
                if (data_in == 0)
                    next_state = S2;
                else if (data_in == 1)
                    next_state = S1;
                else
                    next_state = IDLE;
            end
            S2: begin
                if (data_in == 0)
                    next_state = S3;
                else
                    next_state = IDLE;
            end
            S3: begin
                if (data_in == 1)
                    next_state = IDLE;
                else
                    next_state = S2;
            end
            default: begin
                next_state = IDLE;
            end
        endcase
    end

endmodule