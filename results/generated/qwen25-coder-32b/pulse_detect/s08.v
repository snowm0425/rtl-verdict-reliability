module pulse_detect (
    input wire clk,      // Clock signal
    input wire rst_n,    // Reset signal (active low)
    input wire data_in,  // One-bit input signal
    output reg data_out  // Output signal indicating the presence of pulses
);

    // State encoding
    // 2-bit state register to track the pulse detection process
    reg [1:0] state;

    // State definitions
    localparam IDLE   = 2'b00;
    localparam RISE   = 2'b01;
    localparam FALL   = 2'b10;

    // Initialize the state and data_out in the reset condition
    always @(posedge clk or negedge rst_n) begin
        if (~rst_n) begin
            // Reset state and data_out to initial values
            state <= IDLE;
            data_out <= 0;
        end else begin
            // State machine logic
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
                    if (data_in == 1'b1) begin
                        state <= RISE;
                    end else begin
                        state <= IDLE;
                    end
                    data_out <= 1;  // Pulse detected, set data_out to 1
                end

                default: begin
                    state <= IDLE;
                    data_out <= 0;
                end
            endcase
        end
    end
endmodule