module fsm (
    input  IN,      // Input signal
    input  CLK,     // Clock signal
    input  RST,     // Reset signal (active high)
    output reg MATCH // Output signal indicating match
);

    // State encoding
    localparam S0 = 2'b00; // Initial state
    localparam S1 = 2'b01; // Matched '1'
    localparam S2 = 2'b10; // Matched '10'
    localparam S3 = 2'b11; // Matched '100'
    // Note: S4 is not explicitly needed as a state if we use Mealy logic correctly,
    // but for clarity, we can have 5 states or optimize. 
    // Let's use 5 states for clarity: S0-S4 where S4 means we have matched '1001'
    // Actually, a standard 5-state Mealy machine for 10011:
    // S0: Start
    // S1: 1
    // S2: 10
    // S3: 100
    // S4: 1001
    // If in S4 and IN=1, MATCH=1 and next state is S1 (because the last '1' can be the start of a new sequence)
    
    // Let's redefine states to be explicit:
    localparam STATE_S0 = 3'b000; // Start / No prefix matched
    localparam STATE_S1 = 3'b001; // Matched '1'
    localparam STATE_S2 = 3'b010; // Matched '10'
    localparam STATE_S3 = 3'b011; // Matched '100'
    localparam STATE_S4 = 3'b100; // Matched '1001'

    reg [2:0] current_state, next_state;

    // Mealy Output: MATCH is 1 when current_state is S4 and IN is 1
    // We can assign this in a combinational block or directly in the state transition logic.
    // Since it's a Mealy machine, the output depends on current state and input.
    
    // State register
    always @(posedge CLK) begin
        if (RST)
            current_state <= STATE_S0;
        else
            current_state <= next_state;
    end

    // Next state logic and Mealy output logic
    always @(*) begin
        // Default values
        next_state = current_state;
        MATCH = 1'b0; // Default output is 0

        case (current_state)
            STATE_S0: begin
                if (IN == 1'b1)
                    next_state = STATE_S1;
                else
                    next_state = STATE_S0;
                // MATCH is 0 here
            end

            STATE_S1: begin
                if (IN == 1'b0)
                    next_state = STATE_S2;
                else // IN == 1
                    next_state = STATE_S1; // Stay in S1 if we see another 1, as '1' is the start of the sequence
                // MATCH is 0 here
            end

            STATE_S2: begin
                if (IN == 1'b0)
                    next_state = STATE_S3;
                else // IN == 1
                    next_state = STATE_S1; // If we see 1 after '10', we have '101', the last '1' starts a new sequence
                // MATCH is 0 here
            end

            STATE_S3: begin
                if (IN == 1'b1)
                    next_state = STATE_S4;
                else // IN == 0
                    next_state = STATE_S0; // '1000' breaks the sequence, reset to start
                // MATCH is 0 here
            end

            STATE_S4: begin
                if (IN == 1'b1) begin
                    // Sequence '10011' detected
                    MATCH = 1'b1;
                    // The last '1' in '10011' can be the start of a new sequence '1...'
                    next_state = STATE_S1;
                end
                else begin // IN == 0
                    // '10010' - The last bit is 0, which doesn't start a new sequence, 
                    // but we need to check if any suffix matches.
                    // '10010' ends with '0'. No prefix of '10011' ends with '0' except possibly if we consider...
                    // Actually, '10010' does not have a valid prefix for the next character.
                    // Let's re-evaluate:
                    // Sequence: 1 0 0 1 1
                    // If we are in S4 (1001) and get 0, we have 10010.
                    // Does '10010' end with a prefix of '10011'?
                    // Prefixes: '', '1', '10', '100', '1001'
                    // '10010' ends with '0', '10', '010', '0100', '0010', '10010'
                    // None of these are prefixes of '10011' except empty string.
                    // So we go to S0.
                    next_state = STATE_S0;
                end
            end

            default:
                next_state = STATE_S0;
        endcase
    end

endmodule