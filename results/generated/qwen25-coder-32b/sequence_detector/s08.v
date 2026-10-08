module sequence_detector (
    input wire clk,          // Clock signal to synchronize the detector
    input wire reset_n,      // Reset signal to initialize the state machine (active low)
    input wire data_in,      // 1-bit binary input signal
    output reg sequence_detected // 1-bit output signal set high when the sequence is detected
);

    // Define the states of the FSM
    typedef enum reg [1:0] {
        IDLE = 2'b00,
        S1 = 2'b01,
        S2 = 2'b10,
        S3 = 2'b11
    } state_t;

    // Internal state register
    reg [1:0] current_state;
    reg [1:0] next_state;

    // State register
    always @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            current_state <= IDLE;
        end else begin
            current_state <= next_state;
        end
    end

    // Next state logic
    always @(*) begin
        case (current_state)
            IDLE: begin
                if (data_in == 1'b1) begin
                    next_state = S1;
                end else begin
                    next_state = IDLE;
                end
            end

            S1: begin
                if (data_in == 1'b0) begin
                    next_state = S2;
                end else begin
                    next_state = IDLE;
                end
            end

            S2: begin
                if (data_in == 1'b0) begin
                    next_state = S3;
                end else begin
                    next_state = IDLE;
                end
            end

            S3: begin
                if (data_in == 1'b1) begin
                    next_state = IDLE;
                    sequence_detected = 1'b1; // Sequence detected!
                end else begin
                    next_state = IDLE;
                end
            end

            default: begin
                next_state = IDLE;
            end
        endcase
    end

    // Sequence detected output logic
    always @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            sequence_detected <= 1'b0;
        end else if (current_state == S3 && data_in == 1'b1) begin
            sequence_detected <= 1'b1;
        end else begin
            sequence_detected <= 1'b0;
        end
    end

endmodule