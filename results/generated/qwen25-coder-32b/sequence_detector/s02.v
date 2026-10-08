module sequence_detector (
    input wire clk,         // Clock signal
    input wire reset_n,     // Reset signal (active low)
    input wire data_in,     // 1-bit input signal
    output reg sequence_detected // 1-bit output signal
);

    // Define the states
    typedef enum reg [1:0] {
        IDLE,
        S1,
        S2,
        S3,
        S4
    } state_t;

    // State registers
    state_t current_state;
    state_t next_state;

    // State transition logic
    always @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            current_state <= IDLE;
            sequence_detected <= 0;
        end else begin
            current_state <= next_state;
            sequence_detected <= (current_state == S4);
        end
    end

    // Next state and output logic
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
                next_state = IDLE; // Once the sequence is detected, we can either stay in S4 or reset to IDLE
            end
            default: begin
                next_state = IDLE;
            end
        endcase
    end

endmodule