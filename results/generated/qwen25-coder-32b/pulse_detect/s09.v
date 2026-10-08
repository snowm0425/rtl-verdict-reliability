module pulse_detect (
    input wire clk,       // Clock signal
    input wire rst_n,     // Reset signal (active low)
    input wire data_in,   // One-bit input signal
    output reg data_out   // Output signal indicating the presence of pulses
);

    // State encoding:
    // 2-bit state register: 00 - idle, 01 - detected 0 to 1, 10 - detected 1 to 0
    reg [1:0] state;
    reg [1:0] next_state;

    // State machine logic
    always @(posedge clk or negedge rst_n) begin
        if (~rst_n) begin
            state <= 2'b00;    // Idle state
            data_out <= 1'b0;  // No pulse detected
        end else begin
            state <= next_state;
            case (state)
                2'b00: // Idle state
                    if (data_in == 1'b1)
                        next_state <= 2'b01;  // Transition to 01 state on detection of 0 to 1
                    else
                        next_state <= 2'b00;  // Stay in idle state
                2'b01: // Detected 0 to 1
                    if (data_in == 1'b0)
                        next_state <= 2'b10;  // Transition to 10 state on detection of 1 to 0
                    else
                        next_state <= 2'b01;  // Stay in 01 state
                2'b10: // Detected 1 to 0
                    next_state <= 2'b00;  // Go back to idle state
                default:
                    next_state <= 2'b00;  // Default to idle state
            endcase
        end
    end

    // Output generation
    always @(posedge clk or negedge rst_n) begin
        if (~rst_n) begin
            data_out <= 1'b0;  // No pulse detected
        end else begin
            data_out <= (state == 2'b10) ? 1'b1 : 1'b0;  // Set data_out to 1 if in 10 state, else 0
        end
    end

endmodule