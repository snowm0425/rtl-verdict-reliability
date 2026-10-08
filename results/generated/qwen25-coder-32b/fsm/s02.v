module fsm (
    input CLK,    // Clock signal
    input RST,    // Reset signal
    input IN,     // Input signal
    output reg MATCH  // Output signal indicating a match
);

    // Define the states
    typedef enum reg [2:0] {
        S0, S1, S2, S3, S4
    } state_t;

    // Current and next state registers
    state_t current_state, next_state;

    // State transition logic
    always @(posedge CLK or posedge RST) begin
        if (RST)
            current_state <= S0;
        else
            current_state <= next_state;
    end

    // Next state logic and output logic
    always @(*) begin
        case (current_state)
            S0: begin
                if (IN == 1'b1)
                    next_state = S1;
                else
                    next_state = S0;
                MATCH = 1'b0;
            end
            S1: begin
                if (IN == 1'b0)
                    next_state = S2;
                else
                    next_state = S0;
                MATCH = 1'b0;
            end
            S2: begin
                if (IN == 1'b0)
                    next_state = S3;
                else
                    next_state = S0;
                MATCH = 1'b0;
            end
            S3: begin
                if (IN == 1'b1)
                    next_state = S4;
                else
                    next_state = S0;
                MATCH = 1'b0;
            end
            S4: begin
                if (IN == 1'b1)
                    next_state = S4;  // Stay in S4 to support continuous detection
                else
                    next_state = S0;
                MATCH = 1'b1;  // Output MATCH as 1 when sequence 10011 is detected
            end
            default: begin
                next_state = S0;
                MATCH = 1'b0;
            end
        endcase
    end

endmodule