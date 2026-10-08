module pulse_detect (
    input clk,      // Clock signal
    input rst_n,    // Reset signal (active low)
    input data_in,  // One-bit input signal
    output reg data_out // Output signal indicating the presence of pulses
);

    // Define states for pulse detection
    typedef enum reg [1:0] {
        IDLE = 2'b00,
        RISING_EDGE = 2'b01,
        HIGH = 2'b10
    } state_t;

    // State register
    reg [1:0] state;

    // State machine
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
                        state <= RISING_EDGE;
                    end else begin
                        state <= IDLE;
                    end
                    data_out <= 0;
                end

                RISING_EDGE: begin
                    if (data_in == 1'b0) begin
                        state <= IDLE;
                    end else if (data_in == 1'b1) begin
                        state <= HIGH;
                    end
                    data_out <= 0;
                end

                HIGH: begin
                    if (data_in == 1'b0) begin
                        state <= IDLE;
                        data_out <= 1;  // Pulse detected
                    end else if (data_in == 1'b1) begin
                        state <= HIGH;
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