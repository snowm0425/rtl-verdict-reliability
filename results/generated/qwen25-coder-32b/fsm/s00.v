module fsm (
    input wire IN,
    input wire CLK,
    input wire RST,
    output reg MATCH
);

    // Define the states
    typedef enum reg [2:0] {
        S0, S1, S2, S3, S4
    } state_t;

    // Current and next state signals
    state_t current_state, next_state;

    // State register
    always @(posedge CLK or posedge RST) begin
        if (RST) begin
            current_state <= S0;
            MATCH <= 0;
        end else begin
            current_state <= next_state;
            if (current_state == S4 && IN == 1) begin
                MATCH <= 1;
            end else begin
                MATCH <= 0;
            end
        end
    end

    // Next state logic
    always @(*) begin
        case (current_state)
            S0: begin
                if (IN == 1) next_state = S1;
                else next_state = S0;
            end
            S1: begin
                if (IN == 0) next_state = S2;
                else next_state = S0;
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
                if (IN == 1) next_state = S4;
                else if (IN == 0) next_state = S2;
                else next_state = S0;
            end
            default: next_state = S0;
        endcase
    end

endmodule