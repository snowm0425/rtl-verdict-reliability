module pulse_detect (
    input clk,      // Clock signal
    input rst_n,    // Reset signal (active low)
    input data_in,  // One-bit input signal
    output reg data_out // Output signal indicating the presence of pulses
);

    // Declare a state machine with three states
    typedef enum reg [1:0] {
        IDLE,
        RISING_EDGE,
        FALLING_EDGE
    } state_t;

    // Register to hold the current state
    reg [1:0] state;

    // Always block sensitive to the positive edge of clk and negative edge of rst_n
    always @(posedge clk or negedge rst_n) begin
        if (~rst_n) begin
            // Reset condition
            state <= IDLE;
            data_out <= 0;
        end else begin
            // State transition logic
            case (state)
                IDLE: begin
                    if (data_in) begin
                        state <= RISING_EDGE;
                        data_out <= 0;
                    end else begin
                        state <= IDLE;
                        data_out <= 0;
                    end
                end

                RISING_EDGE: begin
                    if (data_in) begin
                        state <= RISING_EDGE;
                        data_out <= 0;
                    end else begin
                        state <= FALLING_EDGE;
                        data_out <= 1; // Pulse detected
                    end
                end

                FALLING_EDGE: begin
                    if (data_in) begin
                        state <= RISING_EDGE;
                        data_out <= 0;
                    end else begin
                        state <= IDLE;
                        data_out <= 0;
                    end
                end

                default: begin
                    state <= IDLE;
                    data_out <= 0;
                end
            endcase
        end
    end

endmodule