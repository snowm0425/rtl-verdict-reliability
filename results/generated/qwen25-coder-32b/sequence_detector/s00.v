module sequence_detector (
    input wire clk,          // Clock signal
    input wire reset_n,      // Active low reset signal
    input wire data_in,      // 1-bit input data
    output reg sequence_detected // Output signal indicating the sequence is detected
);

    // Define the states of the FSM
    typedef enum reg [1:0] {
        IDLE = 2'b00,
        S1   = 2'b01,
        S2   = 2'b10,
        S3   = 2'b11
    } state_t;

    // Current and next state registers
    state_t current_state, next_state;

    // State machine process
    always @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            current_state <= IDLE;
            sequence_detected <= 0;
        end else begin
            current_state <= next_state;
            if (current_state == S4)
                sequence_detected <= 1;
            else
                sequence_detected <= 0;
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
                next_state = IDLE;  // Reset to IDLE after detection
            end

            default: begin
                next_state = IDLE;
            end
        endcase
    end

endmodule