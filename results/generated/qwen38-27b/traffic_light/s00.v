module traffic_light (
    input  wire rst_n,
    input  wire clk,
    input  wire pass_request,
    output reg  [7:0] clock,
    output reg  red,
    output reg  yellow,
    output reg  green
);

    // Parameters for states
    localparam [1:0] idle       = 2'd0;
    localparam [1:0] s1_red     = 2'd1;
    localparam [1:0] s2_yellow  = 2'd2;
    localparam [1:0] s3_green   = 2'd3;

    // Registers
    reg [7:0] cnt;
    reg [1:0] state;
    reg       p_red;
    reg       p_yellow;
    reg       p_green;

    // Assign clock output
    assign clock = cnt;

    // First always block: State transition logic
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state <= idle;
            p_red <= 1'b0;
            p_yellow <= 1'b0;
            p_green <= 1'b0;
        end else begin
            case (state)
                idle: begin
                    state <= s1_red;
                    p_red <= 1'b1;
                    p_yellow <= 1'b0;
                    p_green <= 1'b0;
                end
                s1_red: begin
                    if (cnt == 8'd1) begin
                        state <= s3_green;
                        p_red <= 1'b0;
                        p_yellow <= 1'b0;
                        p_green <= 1'b1;
                    end else begin
                        state <= s1_red;
                        p_red <= 1'b1;
                        p_yellow <= 1'b0;
                        p_green <= 1'b0;
                    end
                end
                s2_yellow: begin
                    if (cnt == 8'd1) begin
                        state <= s1_red;
                        p_red <= 1'b1;
                        p_yellow <= 1'b0;
                        p_green <= 1'b0;
                    end else begin
                        state <= s2_yellow;
                        p_red <= 1'b0;
                        p_yellow <= 1'b1;
                        p_green <= 1'b0;
                    end
                end
                s3_green: begin
                    if (cnt == 8'd1) begin
                        state <= s2_yellow;
                        p_red <= 1'b0;
                        p_yellow <= 1'b1;
                        p_green <= 1'b0;
                    end else begin
                        state <= s3_green;
                        p_red <= 1'b0;
                        p_yellow <= 1'b0;
                        p_green <= 1'b1;
                    end
                end
                default: begin
                    state <= idle;
                    p_red <= 1'b0;
                    p_yellow <= 1'b0;
                    p_green <= 1'b0;
                end
            endcase
        end
    end

    // Second always block: Counter logic
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            cnt <= 8'd10;
        end else begin
            if (pass_request && green) begin
                // If pedestrian button is pressed during green, shorten to 10 if remaining > 10
                if (cnt > 8'd10)
                    cnt <= 8'd10;
                else
                    cnt <= cnt - 1'b1;
            end
            else if (!green && p_green) begin
                // Transition from green to yellow: set to 5
                cnt <= 8'd5;
            end
            else if (!yellow && p_yellow) begin
                // Transition from yellow to red: set to 10
                cnt <= 8'd10;
            end
            else if (!red && p_red) begin
                // Transition from red to green: set to 60
                cnt <= 8'd60;
            end
            else begin
                // Default: decrement
                if (cnt != 8'd0)
                    cnt <= cnt - 1'b1;
            end
        end
    end

    // Final always block: Output signals
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            red <= 1'b0;
            yellow <= 1'b0;
            green <= 1'b0;
        end else begin
            red <= p_red;
            yellow <= p_yellow;
            green <= p_green;
        end
    end

endmodule