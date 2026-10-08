module traffic_light (
    input rst_n,          // Reset signal (active low)
    input clk,            // Clock signal
    input pass_request,   // Request signal for allowing vehicles to pass

    output reg [7:0] clock, // An 8-bit output representing the count value of the internal counter
    output reg red,       // Output signal representing the red light
    output reg yellow,    // Output signal representing the yellow light
    output reg green      // Output signal representing the green light
);

    // State definitions
    typedef enum reg [1:0] {
        idle = 2'b00,
        s1_red = 2'b01,
        s2_yellow = 2'b10,
        s3_green = 2'b11
    } state_t;

    // Internal registers
    reg [7:0] cnt;       // 8-bit register used as an internal counter for timing purposes
    reg [1:0] state;     // 2-bit register representing the current state of the traffic light controller
    reg p_red, p_yellow, p_green; // 1-bit registers representing the previous values for the red, yellow, and green signals

    // State transition logic
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state <= idle;
        end else begin
            case (state)
                idle: begin
                    state <= s3_green; // Start with green light
                end
                s1_red: begin
                    if (cnt == 0) begin
                        state <= s3_green;
                    end
                end
                s2_yellow: begin
                    if (cnt == 0) begin
                        state <= s1_red;
                    end
                end
                s3_green: begin
                    if (cnt == 0 || (pass_request && green)) begin
                        state <= s2_yellow;
                    end
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
                    if (p_red && !red) begin
                        cnt <= 10;
                    end else if (cnt != 0) begin
                        cnt <= cnt - 1;
                    end
                end
                s2_yellow: begin
                    if (p_yellow && !yellow) begin
                        cnt <= 5;
                    end else if (cnt != 0) begin
                        cnt <= cnt - 1;
                    end
                end
                s3_green: begin
                    if (p_green && !green) begin
                        cnt <= 60;
                    end else if (pass_request && green && cnt > 10) begin
                        cnt <= 10;
                    end else if (cnt != 0) begin
                        cnt <= cnt - 1;
                    end
                end
            endcase
        end
    end

    // Output signals logic
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

    // Assign the value of the internal counter (cnt) to the output clock
    assign clock = cnt;

    // Update previous values
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            p_red <= 0;
            p_yellow <= 0;
            p_green <= 0;
        end else begin
            p_red <= red;
            p_yellow <= yellow;
            p_green <= green;
        end
    end

endmodule