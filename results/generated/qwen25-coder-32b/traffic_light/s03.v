module traffic_light (
    input wire rst_n,        // Reset signal (active low)
    input wire clk,          // Clock signal
    input wire pass_request, // Request signal for allowing vehicles to pass

    output reg [7:0] clock,  // An 8-bit output representing the count value of the internal counter
    output reg red,          // Red light signal
    output reg yellow,       // Yellow light signal
    output reg green         // Green light signal
);

    // Parameter definitions for states
    parameter idle = 2'b00;
    parameter s1_red = 2'b01;
    parameter s2_yellow = 2'b10;
    parameter s3_green = 2'b11;

    // Registers for state, counter, and previous signal values
    reg [1:0] state;
    reg [7:0] cnt;
    reg p_red, p_yellow, p_green;

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
                    if (cnt == 0) state <= s3_green;
                end
                s2_yellow: begin
                    if (cnt == 0) state <= s1_red;
                end
                s3_green: begin
                    if (cnt == 0) state <= s2_yellow;
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
                    if (p_green && pass_request) begin
                        cnt <= 10;
                    end else if (p_green) begin
                        cnt <= 60;
                    end else if (cnt > 0) begin
                        cnt <= cnt - 1;
                    end
                end
                s2_yellow: begin
                    if (p_green) begin
                        cnt <= 5;
                    end else if (cnt > 0) begin
                        cnt <= cnt - 1;
                    end
                end
                s3_green: begin
                    if (p_green && pass_request && cnt > 10) begin
                        cnt <= 10;
                    end else if (cnt > 0) begin
                        cnt <= cnt - 1;
                    end
                end
                default: begin
                    cnt <= 10;
                end
            endcase
        end
    end

    // Output logic
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
                default: begin
                    red <= 0;
                    yellow <= 0;
                    green <= 0;
                end
            endcase
        end
    end

    // Assign previous values for signals
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

    // Assign counter value to output
    assign clock = cnt;

endmodule