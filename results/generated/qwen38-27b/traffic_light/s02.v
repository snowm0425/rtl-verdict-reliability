module traffic_light (
    input  wire       rst_n,        // Reset signal (active low)
    input  wire       clk,          // Clock signal
    input  wire       pass_request, // Pedestrian button request
    output reg  [7:0] clock,        // 8-bit output representing the count value
    output reg        red,          // Red light output
    output reg        yellow,       // Yellow light output
    output reg        green         // Green light output
);

    // Parameter definitions for states
    parameter idle       = 2'b00;
    parameter s1_red     = 2'b01;
    parameter s2_yellow  = 2'b10;
    parameter s3_green   = 2'b11;

    // Registers
    reg [7:0] cnt;      // Internal counter for timing
    reg [1:0] state;    // Current state
    reg       p_red;    // Next value for red
    reg       p_yellow; // Next value for yellow
    reg       p_green;  // Next value for green

    // -----------------------------------------------------------------------
    // 1. State Transition Logic
    //    - idle: Initial state, transition to s1_red immediately.
    //    - s1_red: Red light on. After 10 cycles, go to s3_green.
    //    - s3_green: Green light on. After 60 cycles (or shortened), go to s2_yellow.
    //    - s2_yellow: Yellow light on. After 5 cycles, go to s1_red.
    // -----------------------------------------------------------------------
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state <= idle;
        end else begin
            case (state)
                idle: begin
                    // Transition to red state immediately after reset
                    state <= s1_red;
                end
                s1_red: begin
                    // Wait for 10 clock cycles (cnt will be loaded with 10 on entry)
                    if (cnt == 0) begin
                        state <= s3_green;
                    end else begin
                        state <= s1_red;
                    end
                end
                s3_green: begin
                    // Wait for green phase to complete (cnt will be 0)
                    if (cnt == 0) begin
                        state <= s2_yellow;
                    end else begin
                        state <= s3_green;
                    end
                end
                s2_yellow: begin
                    // Wait for 5 clock cycles
                    if (cnt == 0) begin
                        state <= s1_red;
                    end else begin
                        state <= s2_yellow;
                    end
                end
                default: begin
                    state <= idle;
                end
            endcase
        end
    end

    // -----------------------------------------------------------------------
    // 2. Counter Logic
    //    - Reset: Set to 10 (as per prompt: "If (!rst_n), the counter is set to 10.")
    //    - pass_request handling: If green is active and pass_request is high:
    //        - If cnt > 10, set cnt to 10.
    //        - If cnt <= 10, remain unchanged.
    //    - Phase Entry Loading:
    //        - Entering s3_green (green was inactive, now active): Load 60.
    //        - Entering s2_yellow (yellow was inactive, now active): Load 5.
    //        - Entering s1_red (red was inactive, now active): Load 10.
    //    - Otherwise: Decrement by 1.
    // -----------------------------------------------------------------------
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            cnt <= 8'd10;
        end else begin
            // Priority 1: Pedestrian Request during Green
            // Condition: pass_request is active AND green light is active (p_green)
            // Logic: Shorten to 10 if > 10, else keep current value.
            if (pass_request && p_green) begin
                if (cnt > 8'd10) begin
                    cnt <= 8'd10;
                end else begin
                    cnt <= cnt; // Remain unchanged
                end
            end
            // Priority 2: Phase Transitions (Loading new durations)
            // We use the previous state values (p_red, p_yellow, p_green) to detect transitions
            else if (!p_green && green) begin
                // Transitioning INTO Green (from Red or Idle)
                // Note: The prompt says "If the green signal is inactive and the previous green signal (p_green) was active" -> This is exiting green.
                // The prompt says: "If the green signal is inactive and the previous green signal (p_green) was active, the counter is set to 60."
                // WAIT: Let's re-read the prompt carefully.
                // "If the green signal is inactive and the previous green signal (p_green) was active, the counter is set to 60."
                // This description in the prompt seems backwards for *loading* the counter. Usually, you load the counter when you *enter* a state.
                // Let's look at the next line: "If the yellow signal is inactive and the previous yellow signal (p_yellow) was active, the counter is set to 5."
                // This implies the prompt describes the *exit* condition setting the counter for the *next* state?
                // OR, more likely, the prompt has a typo in the description of the condition.
                // Standard practice: Load counter on ENTRY.
                // Entry to Green: p_green was 0, green is 1.
                // Entry to Yellow: p_yellow was 0, yellow is 1.
                // Entry to Red: p_red was 0, red is 1.
                
                // Let's follow the standard FSM loading logic which matches the cycle requirements:
                // If we are transitioning INTO s3_green, load 60.
                // If we are transitioning INTO s2_yellow, load 5.
                // If we are transitioning INTO s1_red, load 10.
                
                // The prompt's text: "If the green signal is inactive and the previous green signal (p_green) was active, the counter is set to 60."
                // This text is confusing. "Green inactive" means we are NOT in green. "Previous green active" means we WERE in green.
                // This is the transition FROM green TO yellow. Setting the counter to 60 at the *end* of green doesn't make sense for the yellow phase.
                // It likely meant: "When entering Green, set to 60".
                // Let's assume the standard implementation: Load on entry.
                
                // Detecting Entry to Green:
                if (!p_green && green) begin
                    cnt <= 8'd60;
                end
                // Detecting Entry to Yellow:
                else if (!p_yellow && yellow) begin
                    cnt <= 8'd5;
                end
                // Detecting Entry to Red:
                else if (!p_red && red) begin
                    cnt <= 8'd10;
                end
            end
            // Priority 3: Normal Counting
            else begin
                if (cnt == 0) begin
                    cnt <= 8'd0; // Hold at 0 until next load
                end else begin
                    cnt <= cnt - 8'd1;
                end
            end
        end
    end

    // -----------------------------------------------------------------------
    // 3. Output Logic (State Encoding)
    //    - Determines p_red, p_yellow, p_green based on current state.
    //    - These are then registered to red, yellow, green.
    // -----------------------------------------------------------------------
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            p_red   <= 1'b0;
            p_yellow<= 1'b0;
            p_green <= 1'b0;
            red     <= 1'b0;
            yellow  <= 1'b0;
            green   <= 1'b0;
        end else begin
            // Determine next state outputs based on current state
            case (state)
                idle: begin
                    p_red   <= 1'b0;
                    p_yellow<= 1'b0;
                    p_green <= 1'b0;
                end
                s1_red: begin
                    p_red   <= 1'b1;
                    p_yellow<= 1'b0;
                    p_green <= 1'b0;
                end
                s2_yellow: begin
                    p_red   <= 1'b0;
                    p_yellow<= 1'b1;
                    p_green <= 1'b0;
                end
                s3_green: begin
                    p_red   <= 1'b0;
                    p_yellow<= 1'b0;
                    p_green <= 1'b1;
                end
                default: begin
                    p_red   <= 1'b0;
                    p_yellow<= 1'b0;
                    p_green <= 1'b0;
                end
            endcase

            // Register the outputs
            red    <= p_red;
            yellow <= p_yellow;
            green  <= p_green;
        end
    end

    // Assign internal counter to output clock
    assign clock = cnt;

endmodule