module pulse_detect (
    input  wire clk,
    input  wire rst_n,
    input  wire data_in,
    output reg  data_out
);

    // State encoding for pulse detection
    // We need to detect the pattern: 0 -> 1 -> 0 (three cycles)
    // State 0: Waiting for a rising edge (data_in goes from 0 to 1)
    // State 1: Detected rising edge, waiting for falling edge (data_in goes from 1 to 0)
    // State 2: Detected falling edge, this is the end of the pulse. Output data_out = 1 here.
    // Then return to State 0.

    // Let's define states:
    // S0: Initial/Idle state. Previous data_in was 0 or unknown. We are looking for data_in to become 1 (rising edge).
    // S1: Previous data_in was 1 (we just saw a rising edge or we are in the high state). We are looking for data_in to become 0 (falling edge).
    // S2: This state is not really a persistent state; rather, the falling edge detection happens in S1 when data_in becomes 0.
    //     Actually, let's think more carefully.

    // The problem says: "When data_in changes from 0 to 1 to 0 (3 cycles), this is considered as a 'pulse'."
    // And: "The indicating signal dataout is 1 at the end cycle of the 'pulse'"

    // Let's trace the example: data_in = 0 1 0 1 0 (5 cycles)
    // data_out  = 0 0 1 0 1

    // Cycle 0: data_in = 0
    // Cycle 1: data_in = 1
    // Cycle 2: data_in = 0  -> data_out = 1 (end of first pulse)
    // Cycle 3: data_in = 1
    // Cycle 4: data_in = 0  -> data_out = 1 (end of second pulse)

    // So we need to detect the transition from 1 to 0, but only if the previous state was "after a rising edge from 0".

    // Let's use a state machine with the previous value of data_in and a flag.
    // Actually, we can track:
    // - prev_data_in: the value of data_in in the previous cycle
    // - state: whether we are in a "valid pulse sequence"

    // Simpler approach:
    // We need to detect the pattern where:
    // - Two cycles ago: data_in was 0
    // - One cycle ago: data_in was 1
    // - Current cycle: data_in is 0
    // If this pattern is detected, data_out = 1.

    // But we also need to ensure that we don't double-count or miss pulses.
    // Let's use a state machine:
    // State 0 (IDLE): No pulse in progress. Previous data_in doesn't matter or was 0.
    //   - If data_in == 1, go to State 1 (RISING_DETECTED)
    //   - If data_in == 0, stay in State 0
    //
    // State 1 (RISING_DETECTED): We just saw a rising edge (data_in went from 0 to 1).
    //   - If data_in == 0, this is the falling edge, output data_out = 1, go to State 0
    //   - If data_in == 1, stay in State 1 (still high, wait for falling edge)
    //
    // Wait, but what if data_in stays 1 for multiple cycles? The problem says "0 to 1 to 0 (3 cycles)", implying exactly 3 cycles? Or does it mean the pattern of transitions?
    //
    // Let's re-read: "When 'data_in' changes from 0 to 1 to 0(3 cycles), this is considered as a 'pulse'."
    // This likely means the transition sequence: cycle i: 0, cycle i+1: 1, cycle i+2: 0. That's 3 cycles total.
    //
    // But in the example: data_in = 01010, data_out = 00101.
    // Cycle 0: 0
    // Cycle 1: 1
    // Cycle 2: 0 -> pulse detected
    // Cycle 3: 1
    // Cycle 4: 0 -> pulse detected
    //
    // So it's detecting every occurrence of the pattern 0-1-0.
    //
    // Let's implement with two flip-flops for previous data_in values:
    // - prev1: data_in from previous cycle
    // - prev2: data_in from two cycles ago
    //
    // If prev2 == 0, prev1 == 1, and data_in == 0, then data_out = 1.
    //
    // But we need to be careful: what if there's a longer high pulse? E.g., 0-1-1-0. 
    // In this case, should we detect a pulse? The problem says "0 to 1 to 0 (3 cycles)", which suggests exactly the 3-cycle pattern.
    // But the example only shows single-cycle pulses. Let's assume that any 0-1-0 transition (where the 1 might be held for more than 1 cycle) should be detected at the falling edge.
    //
    // Actually, re-reading more carefully: "changes from 0 to 1 to 0(3 cycles)" - this is a bit ambiguous. But the example clarifies: each 0-1-0 sequence generates one pulse at the final 0.
    //
    // Let's use the state machine approach:
    // State 0: Idle. Looking for a 1.
    //   - If data_in == 1, transition to State 1.
    //   - Else, stay in State 0.
    // State 1: Saw a 1. Looking for a 0.
    //   - If data_in == 0, set data_out = 1, transition to State 0.
    //   - If data_in == 1, stay in State 1.
    //
    // Let's trace with 01010:
    // Cycle 0: data_in=0, state=0 -> state stays 0, data_out=0
    // Cycle 1: data_in=1, state=0 -> state becomes 1, data_out=0
    // Cycle 2: data_in=0, state=1 -> data_out=1, state becomes 0
    // Cycle 3: data_in=1, state=0 -> state becomes 1, data_out=0
    // Cycle 4: data_in=0, state=1 -> data_out=1, state becomes 0
    //
    // This gives data_out = 00101. Correct!
    //
    // Now consider 0110:
    // Cycle 0: data_in=0, state=0 -> state=0, data_out=0
    // Cycle 1: data_in=1, state=0 -> state=1, data_out=0
    // Cycle 2: data_in=1, state=1 -> state=1, data_out=0
    // Cycle 3: data_in=0, state=1 -> data_out=1, state=0
    //
    // This seems reasonable. The pulse is detected at the falling edge after the high period.

    reg state;

    always @(posedge clk or negedge rst_n) begin
        if (~rst_n) begin
            state    <= 0;
            data_out <= 0;
        end else begin
            case (state)
                0: begin
                    if (data_in == 1) begin
                        state    <= 1;
                        data_out <= 0;
                    end else begin
                        state    <= 0;
                        data_out <= 0;
                    end
                end
                1: begin
                    if (data_in == 0) begin
                        state    <= 0;
                        data_out <= 1;
                    end else begin
                        state    <= 1;
                        data_out <= 0;
                    end
                end
                default: begin
                    state    <= 0;
                    data_out <= 0;
                end
            endcase
        end
    end

endmodule