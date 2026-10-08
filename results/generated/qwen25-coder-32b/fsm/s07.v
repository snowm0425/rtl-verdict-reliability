module fsm (
    input CLK,
    input RST,
    input IN,
    output reg MATCH
);

    // Define the states of the FSM
    typedef enum reg [2:0] { S0, S1, S2, S3, S4 } state_t;
    state_t state, next_state;

    // State transition logic
    always @(posedge CLK or posedge RST) begin
        if (RST) begin
            state <= S0;
            MATCH <= 0;
        end else begin
            state <= next_state;
            case (next_state)
                S4: MATCH <= 1; // Match detected
                default: MATCH <= 0;
            endcase
        end
    end

    // Next state logic
    always @(*) begin
        case (state)
            S0: begin
                if (IN == 1) next_state = S1;
                else next_state = S0;
            end
            S1: begin
                if (IN == 0) next_state = S2;
                else next_state = S1;
            end
            S2: begin
                if (IN == 0) next_state = S3;
                else next_state = S1;
            end
            S3: begin
                if (IN == 1) next_state = S4;
                else next_state = S1;
            end
            S4: begin
                if (IN == 1) next_state = S4; // Stay in S4 if another '1' is detected
                else next_state = S1; // Go back to S1 if '0' is detected
            end
            default: next_state = S0;
        endcase
    end

endmodule