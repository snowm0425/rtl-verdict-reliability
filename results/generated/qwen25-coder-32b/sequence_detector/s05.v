module sequence_detector (
    input wire clk,          // Clock signal
    input wire reset_n,      // Active-low reset signal
    input wire data_in,      // 1-bit input data
    output reg sequence_detected  // Output signal indicating sequence detection
);

    // State definitions
    typedef enum reg [1:0] {
        IDLE = 2'b00,
        S1 = 2'b01,
        S2 = 2'b10,
        S3 = 2'b11
    } state_t;

    // Internal state register
    reg [1:0] current_state, next_state;

    // State transition logic
    always @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            current_state <= IDLE;
            sequence_detected <= 0;
        end else begin
            current_state <= next_state;
            if (current_state == S3 && data_in == 1'b1)
                sequence_detected <= 1;
            else
                sequence_detected <= 0;
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
                    next_state = IDLE;  // Sequence detected, reset to IDLE
                else
                    next_state = IDLE;
            end
            default: next_state = IDLE;
        endcase
    end

endmodule