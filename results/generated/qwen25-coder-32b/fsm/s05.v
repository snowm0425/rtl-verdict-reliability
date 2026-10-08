module fsm (
    input wire IN,
    input wire CLK,
    input wire RST,
    output reg MATCH
);

    // Define the states
    typedef enum logic [2:0] {
        IDLE, S1, S2, S3, S4
    } state_t;

    // Current and next state registers
    state_t currentState, nextState;

    // State transition logic
    always_ff @(posedge CLK or posedge RST) begin
        if (RST) begin
            currentState <= IDLE;
            MATCH <= 0;
        end else begin
            currentState <= nextState;
            // Set MATCH to 1 when the sequence 10011 is detected
            if (nextState == S4 && IN == 1)
                MATCH <= 1;
            else
                MATCH <= 0;
        end
    end

    // Next state logic
    always_comb begin
        case (currentState)
            IDLE: begin
                if (IN == 1)
                    nextState = S1;
                else
                    nextState = IDLE;
            end
            S1: begin
                if (IN == 0)
                    nextState = S2;
                else
                    nextState = S1;
            end
            S2: begin
                if (IN == 0)
                    nextState = S3;
                else
                    nextState = S1;
            end
            S3: begin
                if (IN == 1)
                    nextState = S4;
                else
                    nextState = S1;
            end
            S4: begin
                if (IN == 1)
                    nextState = S4;
                else
                    nextState = S1;
            end
            default: begin
                nextState = IDLE;
            end
        endcase
    end

endmodule