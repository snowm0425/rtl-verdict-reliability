module pulse_detect (
    input wire clk,      // Clock signal
    input wire rst_n,    // Reset signal (active low)
    input wire data_in,  // One-bit input signal
    output reg data_out  // Output signal indicating the presence of pulses
);

    // States for the pulse detection state machine
    typedef enum reg [1:0] {
        IDLE    = 2'b00,
        DETECT1 = 2'b01,
        DETECT2 = 2'b10
    } pulse_state_t;

    // Register to keep track of the current state
    reg [1:0] state;

    // State machine process
    always @(posedge clk or negedge rst_n) begin
        if (~rst_n) begin
            // Reset condition
            state <= IDLE;
            data_out <= 0;
        end else begin
            case (state)
                IDLE: begin
                    if (data_in == 1'b1) begin
                        state <= DETECT1;
                    end else begin
                        state <= IDLE;
                    end
                    data_out <= 0;
                end
                DETECT1: begin
                    if (data_in == 1'b0) begin
                        state <= DETECT2;
                    end else begin
                        state <= DETECT1;
                    end
                    data_out <= 0;
                end
                DETECT2: begin
                    if (data_in == 1'b1) begin
                        state <= DETECT1;
                    end else begin
                        state <= IDLE;
                    end
                    data_out <= 1; // Pulse detected, set data_out to 1
                end
                default: begin
                    state <= IDLE;
                    data_out <= 0;
                end
            endcase
        end
    end
endmodule