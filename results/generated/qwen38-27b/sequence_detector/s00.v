module sequence_detector (
    input wire clk,
    input wire reset_n,
    input wire data_in,
    output reg sequence_detected
);

    // State definitions
    localparam IDLE = 2'd0;
    localparam S1   = 2'd1;
    localparam S2   = 2'd2;
    localparam S3   = 2'd3;
    localparam S4   = 2'd4; // This is actually a 3-bit value, but we can use 3 bits for safety

    // Actually, let's use 3 bits to be safe since we have 5 states (0-4)
    localparam [2:0] IDLE = 3'd0;
    localparam [2:0] S1   = 3'd1;
    localparam [2:0] S2   = 3'd2;
    localparam [2:0] S3   = 3'd3;
    localparam [2:0] S4   = 3'd4;

    reg [2:0] current_state;
    reg [2:0] next_state;

    always @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            current_state <= IDLE;
            sequence_detected <= 1'b0;
        end else begin
            current_state <= next_state;
            // Set sequence_detected high when entering S4 (sequence 1001 detected)
            if (next_state == S4)
                sequence_detected <= 1'b1;
            else
                sequence_detected <= 1'b0;
        end
    end

    // Combinational logic for next state
    always @(*) begin
        case (current_state)
            IDLE: begin
                if (data_in == 1'b1)
                    next_state = S1;
                else
                    next_state = IDLE;
            end
            S1: begin
                // We have '1', need '0' next
                if (data_in == 1'b0)
                    next_state = S2;
                else
                    // Still '1', stay in S1
                    next_state = S1;
            end
            S2: begin
                // We have '10', need '0' next
                if (data_in == 1'b0)
                    next_state = S3;
                else
                    // Got '1', could be start of new sequence
                    next_state = S1;
            end
            S3: begin
                // We have '100', need '1' next
                if (data_in == 1'b1)
                    next_state = S4;
                else
                    // Got '0', sequence broken, go back to IDLE
                    next_state = IDLE;
            end
            S4: begin
                // Sequence detected, reset to IDLE for next detection
                // But also check if the last bit could be part of a new sequence
                // The sequence is 1001. After detecting 1001, the last bit is '1'
                // So if data_in was '1', we might start a new sequence
                // However, since we're in S4, we just go to IDLE and let the next input be handled
                // Actually, we should consider overlap. After 1001, the '1' at the end could be the start of a new '1001'
                // But since we're transitioning out of S4, the next state depends on data_in
                if (data_in == 1'b1)
                    next_state = S1;
                else
                    next_state = IDLE;
            end
            default:
                next_state = IDLE;
        endcase
    end

endmodule