module fsm (
    input IN,
    input CLK,
    input RST,
    output reg MATCH
);

    // Define the states
    typedef enum reg [2:0] {S0, S1, S2, S3, S4} state_t;
    state_t current_state, next_state;

    // State transition logic
    always @(posedge CLK or posedge RST) begin
        if (RST)
            current_state <= S0;
        else
            current_state <= next_state;
    end

    // Next state logic
    always @(*) begin
        case (current_state)
            S0: begin
                if (IN == 1'b1)
                    next_state = S1;
                else
                    next_state = S0;
            end
            S1: begin
                if (IN == 1'b0)
                    next_state = S2;
                else
                    next_state = S0;
            end
            S2: begin
                if (IN == 1'b0)
                    next_state = S3;
                else
                    next_state = S0;
            end
            S3: begin
                if (IN == 1'b1)
                    next_state = S4;
                else
                    next_state = S0;
            end
            S4: begin
                if (IN == 1'b1)
                    next_state = S4;  // Stay in S4 to support continuous detection
                else
                    next_state = S0;
            end
            default: next_state = S0;
        endcase
    end

    // Output logic
    always @(posedge CLK or posedge RST) begin
        if (RST)
            MATCH <= 0;
        else begin
            if (current_state == S4 && IN == 1'b1)
                MATCH <= 1;
            else
                MATCH <= 0;
        end
    end

endmodule