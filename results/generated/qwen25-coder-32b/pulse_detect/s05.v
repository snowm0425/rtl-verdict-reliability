module pulse_detect (
    input clk,      // Clock signal
    input rst_n,    // Reset signal (active low)
    input data_in,  // One-bit input signal
    output reg data_out // Output signal indicating the presence of pulses
);

    // Define states
    typedef enum logic [1:0] {
        IDLE = 2'b00,
        RISE = 2'b01,
        FALL = 2'b10
    } state_t;

    // State register
    reg [1:0] state;

    // State machine logic
    always @(posedge clk or negedge rst_n) begin
        if (~rst_n) begin
            // Reset condition: Set state to IDLE and data_out to 0
            state <= IDLE;
            data_out <= 0;
        end else begin
            // State transition logic
            case (state)
                IDLE: begin
                    if (data_in == 1'b1) begin
                        state <= RISE;
                    end else begin
                        state <= IDLE;
                    end
                    data_out <= 0;
                end

                RISE: begin
                    if (data_in == 1'b0) begin
                        state <= FALL;
                    end else begin
                        state <= RISE;
                    end
                    data_out <= 0;
                end

                FALL: begin
                    if (data_in == 1'b0) begin
                        state <= IDLE;
                        data_out <= 1; // Indicate the end of a pulse
                    end else begin
                        state <= RISE; // If data_in goes back to 1, restart the detection
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