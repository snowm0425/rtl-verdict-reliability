module freq_divbyfrac (
    input clk,        // Input clock signal
    input rst_n,      // Active low reset signal
    output clk_div    // Fractionally divided clock output
);

    // Parameters for 3.5x division
    localparam MUL2_DIV_CLK = 7; // Total clock cycles for one full cycle

    // State machine states
    typedef enum logic [2:0] {
        IDLE = 3'b000,
        COUNT_4 = 3'b001,
        COUNT_3 = 3'b010,
        PHASE_SHIFT_1 = 3'b011,
        PHASE_SHIFT_2 = 3'b100,
        PHASE_SHIFT_3 = 3'b101,
        PHASE_SHIFT_4 = 3'b110,
        PHASE_SHIFT_5 = 3'b111
    } state_t;

    state_t state, next_state;

    // Counters
    logic [2:0] count;

    // Intermediate clock signals
    logic clk_4, clk_3, clk_shifted1, clk_shifted2;
    logic [2:0] phase_shift_count;

    // Output register
    reg clk_div_reg;

    // State machine logic
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state <= IDLE;
            count <= 3'b000;
            phase_shift_count <= 3'b000;
            clk_4 <= 1'b0;
            clk_3 <= 1'b0;
            clk_shifted1 <= 1'b0;
            clk_shifted2 <= 1'b0;
            clk_div_reg <= 1'b0;
        end else begin
            state <= next_state;
            case (state)
                COUNT_4:
                    if (count == 3) begin
                        count <= 3'b000;
                        clk_4 <= 1'b1;
                    end else begin
                        count <= count + 1;
                        clk_4 <= 1'b0;
                    end

                COUNT_3:
                    if (count == 2) begin
                        count <= 3'b000;
                        clk_3 <= 1'b1;
                    end else begin
                        count <= count + 1;
                        clk_3 <= 1'b0;
                    end

                PHASE_SHIFT_1:
                    if (phase_shift_count == 3) begin
                        phase_shift_count <= 3'b000;
                        clk_shifted1 <= 1'b1;
                    end else begin
                        phase_shift_count <= phase_shift_count + 1;
                        clk_shifted1 <= 1'b0;
                    end

                PHASE_SHIFT_2:
                    if (phase_shift_count == 2) begin
                        phase_shift_count <= 3'b000;
                        clk_shifted2 <= 1'b1;
                    end else begin
                        phase_shift_count <= phase_shift_count + 1;
                        clk_shifted2 <= 1'b0;
                    end

                PHASE_SHIFT_3:
                    if (phase_shift_count == 1) begin
                        phase_shift_count <= 3'b000;
                        clk_shifted1 <= 1'b1;
                    end else begin
                        phase_shift_count <= phase_shift_count + 1;
                        clk_shifted1 <= 1'b0;
                    end

                PHASE_SHIFT_4:
                    if (phase_shift_count == 0) begin
                        phase_shift_count <= 3'b000;
                        clk_shifted2 <= 1'b1;
                    end else begin
                        phase_shift_count <= phase_shift_count + 1;
                        clk_shifted2 <= 1'b0;
                    end

                PHASE_SHIFT_5:
                    if (phase_shift_count == 3) begin
                        phase_shift_count <= 3'b000;
                        clk_shifted1 <= 1'b1;
                    end else begin
                        phase_shift_count <= phase_shift_count + 1;
                        clk_shifted1 <= 1'b0;
                    end

                default: // IDLE
                    clk_4 <= 1'b0;
                    clk_3 <= 1'b0;
                    clk_shifted1 <= 1'b0;
                    clk_shifted2 <= 1'b0;
            endcase

            // OR the phase-shifted clocks to produce the final clk_div
            clk_div_reg <= clk_4 | clk_3 | clk_shifted1 | clk_shifted2;
        end
    end

    // Next state logic
    always_comb begin
        case (state)
            IDLE:
                next_state = COUNT_4;

            COUNT_4:
                if (count == 3)
                    next_state = COUNT_3;
                else
                    next_state = COUNT_4;

            COUNT_3:
                if (count == 2)
                    next_state = PHASE_SHIFT_1;
                else
                    next_state = COUNT_3;

            PHASE_SHIFT_1:
                if (phase_shift_count == 3)
                    next_state = PHASE_SHIFT_2;
                else
                    next_state = PHASE_SHIFT_1;

            PHASE_SHIFT_2:
                if (phase_shift_count == 2)
                    next_state = PHASE_SHIFT_3;
                else
                    next_state = PHASE_SHIFT_2;

            PHASE_SHIFT_3:
                if (phase_shift_count == 1)
                    next_state = PHASE_SHIFT_4;
                else
                    next_state = PHASE_SHIFT_3;

            PHASE_SHIFT_4:
                if (phase_shift_count == 0)
                    next_state = PHASE_SHIFT_5;
                else
                    next_state = PHASE_SHIFT_4;

            PHASE_SHIFT_5:
                if (phase_shift_count == 3)
                    next_state = IDLE;
                else
                    next_state = PHASE_SHIFT_5;

            default:
                next_state = IDLE;
        endcase
    end

    // Assign the output
    assign clk_div = clk_div_reg;

endmodule