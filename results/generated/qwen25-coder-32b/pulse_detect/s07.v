module pulse_detect (
    input clk,      // Clock signal
    input rst_n,    // Reset signal (active low)
    input data_in,  // One-bit input signal
    output reg data_out // Output signal indicating the presence of pulses
);

    // State encoding
    typedef enum reg [1:0] {
        IDLE = 2'b00,
        RISE = 2'b01,
        FALL = 2'b10
    } state_t;

    // State register
    reg [1:0] state;

    // Next state register
    reg [1:0] next_state;

    // State machine process
    always @(posedge clk or negedge rst_n) begin
        if (~rst_n) begin
            state <= IDLE;
            data_out <= 0;
        end else begin
            state <= next_state;
            case (state)
                IDLE: begin
                    if (data_in == 1) begin
                        next_state = RISE;
                    end else begin
                        next_state = IDLE;
                    end
                    data_out = 0;
                end

                RISE: begin
                    if (data_in == 0) begin
                        next_state = FALL;
                    end else begin
                        next_state = RISE;
                    end
                    data_out = 0;
                end

                FALL: begin
                    if (data_in == 1) begin
                        next_state = RISE;
                    end else begin
                        next_state = IDLE;
                    end
                    data_out = 1;
                end

                default: begin
                    next_state = IDLE;
                    data_out = 0;
                end
            endcase
        end
    end

endmodule