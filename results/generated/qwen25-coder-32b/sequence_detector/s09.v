module sequence_detector (
    input clk,          // Clock signal
    input reset_n,      // Active-low reset signal
    input data_in,      // 1-bit input signal
    output reg sequence_detected // Output signal indicating sequence detection
);

    // Define states
    typedef enum reg [1:0] {
        IDLE = 2'b00,
        S1 = 2'b01,
        S2 = 2'b10,
        S3 = 2'b11
    } state_t;

    // Current and next state registers
    state_t current_state, next_state;

    // State machine logic
    always @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            current_state <= IDLE;
            sequence_detected <= 0;
        end else begin
            current_state <= next_state;
            sequence_detected <= (current_state == S3 && data_in == 1);
        end
    end

    // Next state logic
    always @(*) begin
        case (current_state)
            IDLE: begin
                if (data_in == 1) begin
                    next_state = S1;
                end else begin
                    next_state = IDLE;
                end
            end
            S1: begin
                if (data_in == 0) begin
                    next_state = S2;
                end else begin
                    next_state = IDLE;
                end
            end
            S2: begin
                if (data_in == 0) begin
                    next_state = S3;
                end else begin
                    next_state = IDLE;
                end
            end
            S3: begin
                if (data_in == 1) begin
                    next_state = S1;
                end else begin
                    next_state = IDLE;
                end
            end
            default: begin
                next_state = IDLE;
            end
        endcase
    end

endmodule