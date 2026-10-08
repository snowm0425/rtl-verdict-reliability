module sequence_detector (
    input clk,           // Clock signal
    input reset_n,       // Active low reset signal
    input data_in,       // 1-bit binary input signal
    output reg sequence_detected // Output signal set high when sequence is detected
);

// Define the states
typedef enum reg [1:0] {
    IDLE = 2'b00,
    S1   = 2'b01,
    S2   = 2'b10,
    S3   = 2'b11
} state_t;

// State register
reg [1:0] state_reg;
reg [1:0] next_state;

// State transition logic
always @(posedge clk or negedge reset_n) begin
    if (!reset_n) begin
        state_reg <= IDLE;
        sequence_detected <= 0;
    end else begin
        state_reg <= next_state;
        if (next_state == S3 && data_in == 1'b1) begin
            sequence_detected <= 1;
        end else begin
            sequence_detected <= 0;
        end
    end
end

// Next state logic
always @(*) begin
    case (state_reg)
        IDLE: begin
            if (data_in == 1'b1)
                next_state = S1;
            else
                next_state = IDLE;
        end

        S1: begin
            if (data_in == 1'b0)
                next_state = S2;
            else
                next_state = IDLE;
        end

        S2: begin
            if (data_in == 1'b0)
                next_state = S3;
            else
                next_state = IDLE;
        end

        S3: begin
            if (data_in == 1'b1)
                next_state = S3; // Stay in S3 if sequence is detected
            else
                next_state = IDLE;
        end

        default: begin
            next_state = IDLE;
        end
    endcase
end

endmodule