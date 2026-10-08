module fsm (
    input IN,
    input CLK,
    input RST,
    output MATCH
);

    // Define the states
    typedef enum logic [2:0] {S0, S1, S2, S3, S4} state_t;
    
    // Current and next state registers
    state_t current_state, next_state;

    // Register for the MATCH output
    logic match_reg;

    // State transition logic
    always_ff @(posedge CLK or posedge RST) begin
        if (RST) begin
            current_state <= S0;
            match_reg <= 0;
        end else begin
            current_state <= next_state;
            match_reg <= (next_state == S4) ? 1 : 0;
        end
    end

    // Next state and output logic
    always_comb begin
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
                    next_state = S4;  // Loop back to S4 if sequence repeats
                else
                    next_state = S0;
            end
            default: begin
                next_state = S0;
            end
        endcase
    end

    // Assign the MATCH output
    assign MATCH = match_reg;

endmodule