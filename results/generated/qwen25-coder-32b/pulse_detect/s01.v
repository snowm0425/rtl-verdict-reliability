module pulse_detect (
    input wire clk,        // Clock signal
    input wire rst_n,      // Reset signal (active low)
    input wire data_in,    // One-bit input signal
    output reg data_out    // Output signal indicating the presence of pulses
);

    // Define states for the state machine
    typedef enum reg [1:0] {
        IDLE = 2'b00,      // Initial state, waiting for pulse start
        RISE = 2'b01,      // Detected rising edge of pulse
        FALL = 2'b10       // Detected falling edge of pulse
    } state_t;

    // State register
    reg [1:0] state;

    // State transition logic
    always @(posedge clk or negedge rst_n) begin
        if (~rst_n) begin
            // Reset condition
            state <= IDLE;
            data_out <= 0;
        end else begin
            // State transition logic
            case (state)
                IDLE: begin
                    if (data_in == 1'b1) begin
                        state <= RISE;
                        data_out <= 0;
                    end else begin
                        state <= IDLE;
                        data_out <= 0;
                    end
                end

                RISE: begin
                    if (data_in == 1'b0) begin
                        state <= FALL;
                        data_out <= 1;  // Pulse detected, set data_out to 1
                    end else begin
                        state <= RISE;
                        data_out <= 0;
                    end
                end

                FALL: begin
                    // After detecting a pulse, go back to idle state
                    state <= IDLE;
                    data_out <= 0;
                end

                default: begin
                    state <= IDLE;
                    data_out <= 0;
                end
            endcase
        end
    end

endmodule