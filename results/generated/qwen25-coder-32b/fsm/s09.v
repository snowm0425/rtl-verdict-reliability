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

    // State registers
    reg [2:0] current_state;
    reg [2:0] next_state;

    // State transition logic
    always @(posedge CLK or posedge RST) begin
        if (RST) begin
            current_state <= S0;
            MATCH <= 0;
        end else begin
            current_state <= next_state;
            case (next_state)
                S4: MATCH <= 1;
                default: MATCH <= 0;
            endcase
        end
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
                    next_state = S4; // Stay in S4 if input is 1 for continuous match detection
                else
                    next_state = S0;
            end
            default: next_state = S0; // Default case
        endcase
    end

endmodule