module sequence_detector (
    input clk,          // Clock signal
    input reset_n,      // Active low reset signal
    input data_in,      // 1-bit input signal
    output reg sequence_detected // Output signal set high when sequence is detected
);

    // Define states for the FSM
    typedef enum logic [1:0] {
        IDLE,
        S1,
        S2,
        S3,
        S4
    } state_t;

    // Internal state register
    state_t state_reg, state_next;

    // State transition logic
    always_ff @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            state_reg <= IDLE;
            sequence_detected <= 0;
        end else begin
            state_reg <= state_next;
            sequence_detected <= (state_next == S4);
        end
    end

    // Next state logic and output logic
    always_comb begin
        case (state_reg)
            IDLE: begin
                if (data_in == 1'b1) begin
                    state_next = S1;
                end else begin
                    state_next = IDLE;
                end
            end
            S1: begin
                if (data_in == 1'b0) begin
                    state_next = S2;
                end else begin
                    state_next = IDLE;
                end
            end
            S2: begin
                if (data_in == 1'b0) begin
                    state_next = S3;
                end else begin
                    state_next = IDLE;
                end
            end
            S3: begin
                if (data_in == 1'b1) begin
                    state_next = S4;
                end else begin
                    state_next = IDLE;
                end
            end
            S4: begin
                state_next = IDLE; // Reset to IDLE after detecting the sequence
            end
            default: begin
                state_next = IDLE; // Default case for safety
            end
        endcase
    end

endmodule