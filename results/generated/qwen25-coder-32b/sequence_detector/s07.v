module sequence_detector (
    input wire clk,          // Clock signal
    input wire reset_n,      // Active low reset signal
    input wire data_in,      // 1-bit binary input signal
    output reg sequence_detected // Output signal set high when sequence is detected
);

    // Define states for the FSM
    typedef enum reg [1:0] {
        IDLE,
        S1,
        S2,
        S3,
        S4
    } state_t;

    // State variables
    state_t current_state, next_state;

    // State machine logic
    always @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            current_state <= IDLE;
            sequence_detected <= 0;
        end else begin
            current_state <= next_state;
            if (current_state == S4) begin
                sequence_detected <= 1;
            end else begin
                sequence_detected <= 0;
            end
        end
    end

    // Next state logic
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
                next_state = IDLE; // Reset to IDLE after detecting the sequence
            end
            default: begin
                next_state = IDLE;
            end
        endcase
    end

endmodule