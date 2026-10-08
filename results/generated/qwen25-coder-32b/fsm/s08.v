module fsm (
    input IN,
    input CLK,
    input RST,
    output reg MATCH
);

    // Define the states
    typedef enum reg [2:0] {
        S0, S1, S2, S3, S4
    } state_t;

    // Declare the current and next states
    state_t current_state, next_state;

    // State transition logic
    always @(posedge CLK or posedge RST) begin
        if (RST) begin
            current_state <= S0;
            MATCH <= 0;
        end else begin
            current_state <= next_state;
            // Set MATCH based on the current state and input
            MATCH <= (current_state == S4) && (IN == 1);
        end
    end

    // Next state logic
    always @(*) begin
        case (current_state)
            S0: begin
                if (IN == 1)
                    next_state = S1;
                else
                    next_state = S0;
            end
            S1: begin
                if (IN == 0)
                    next_state = S2;
                else
                    next_state = S0;
            end
            S2: begin
                if (IN == 0)
                    next_state = S3;
                else
                    next_state = S0;
            end
            S3: begin
                if (IN == 1)
                    next_state = S4;
                else
                    next_state = S0;
            end
            S4: begin
                if (IN == 1)
                    next_state = S4; // Stay in S4 if the sequence is repeated
                else if (IN == 0)
                    next_state = S1; // Go back to S1 if the sequence is broken
                else
                    next_state = S0;
            end
            default: begin
                next_state = S0;
            end
        endcase
    end

endmodule