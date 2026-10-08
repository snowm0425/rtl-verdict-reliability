module traffic_light (
    input wire rst_n,          // Reset signal (active low).
    input wire clk,            // Clock signal.
    input wire pass_request,   // Request signal for allowing vehicles to pass.

    output reg [7:0] clock,    // An 8-bit output representing the count value of the internal counter.
    output reg red,            // Output signal representing the red light.
    output reg yellow,         // Output signal representing the yellow light.
    output reg green           // Output signal representing the green light.
);

    // Enumeration values representing different states of the traffic light controller.
    typedef enum reg [1:0] {
        idle = 2'b00,
        s1_red = 2'b01,
        s2_yellow = 2'b10,
        s3_green = 2'b11
    } state_t;

    // Registers
    reg [7:0] cnt;             // A 8-bit register used as an internal counter for timing purposes.
    reg [1:0] state;           // A 2-bit register representing the current state of the traffic light controller.
    reg p_red, p_yellow, p_green; // 1-bit registers representing the previous values for the red, yellow, and green signals.

    // State transition logic
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state <= idle;
        end else begin
            case (state)
                idle: begin
                    state <= s1_red;
                end
                s1_red: begin
                    if (cnt == 0)
                        state <= s3_green;
                end
                s2_yellow: begin
                    if (cnt == 0)
                        state <= s1_red;
                end
                s3_green: begin
                    if (cnt == 0)
                        state <= s2_yellow;
                    else if (pass_request && green && cnt > 10)
                        state <= s2_yellow; // Shorten green time to yellow
                end
                default: begin
                    state <= idle;
                end
            endcase
        end
    end

    // Counting logic
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            cnt <= 10;
        end else begin
            case (state)
                s1_red: begin
                    if (cnt == 0)
                        cnt <= 60;
                    else
                        cnt <= cnt - 1;
                end
                s2_yellow: begin
                    if (cnt == 0)
                        cnt <= 5;
                    else
                        cnt <= cnt - 1;
                end
                s3_green: begin
                    if (pass_request && cnt > 10)
                        cnt <= 10; // Shorten green time to 10
                    else if (cnt == 0)
                        cnt <= 5;
                    else
                        cnt <= cnt - 1;
                end
                default: begin
                    cnt <= 10;
                end
            endcase
        end
    end

    // Output signals
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            red <= 0;
            yellow <= 0;
            green <= 0;
        end else begin
            case (state)
                s1_red: begin
                    red <= 1;
                    yellow <= 0;
                    green <= 0;
                end
                s2_yellow: begin
                    red <= 0;
                    yellow <= 1;
                    green <= 0;
                end
                s3_green: begin
                    red <= 0;
                    yellow <= 0;
                    green <= 1;
                end
            endcase
        end
    end

    // Assign the value of the internal counter to the output clock
    assign clock = cnt;

endmodule