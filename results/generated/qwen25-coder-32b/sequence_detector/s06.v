module sequence_detector (
    input wire clk,
    input wire reset_n,
    input wire data_in,
    output reg sequence_detected
);

    // Define the states for the FSM
    typedef enum reg [1:0] {
        IDLE,
        S1,
        S2,
        S3,
        S4
    } state_t;

    // Declare current and next state signals
    state_t current_state, next_state;

    // State machine logic
    always @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            // Asynchronous reset to IDLE state
            current_state <= IDLE;
            sequence_detected <= 0;
        end else begin
            // Synchronous state transition
            current_state <= next_state;
            sequence_detected <= (current_state == S4) ? 1 : 0;
        end
    end

    // Next state logic based on current state and data_in
    always @(*) begin
        case (current_state)
            IDLE: begin
                if (data_in == 1'b1)
                    next_state = S1;
                else
                    next_state = IDLE;
            end

            S1: begin
                if (data_in == 1'b0)
                    next_state = S2;
                else
                    next_state = IDLE;
            end

            S2: begin
                if (data_in == 1'b0)
                    next_state = S3;
                else
                    next_state = IDLE;
            end

            S3: begin
                if (data_in == 1'b1)
                    next_state = S4;
                else
                    next_state = IDLE;
            end

            S4: begin
                // Once sequence is detected, stay in S4 until reset or new sequence starts
                next_state = IDLE;
            end

            default: begin
                // Default case to handle unexpected states (should not occur)
                next_state = IDLE;
            end
        endcase
    end

endmodule