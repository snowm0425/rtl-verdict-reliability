module calendar (
    input CLK,        // Clock input
    input RST,        // Active high reset signal
    output [5:0] Hours, // 6-bit output representing the current hours (0-23)
    output [5:0] Mins,  // 6-bit output representing the current minutes (0-59)
    output [5:0] Secs   // 6-bit output representing the current seconds (0-59)
);

    reg [5:0] secs_reg;  // Register to hold the seconds value
    reg [5:0] mins_reg;  // Register to hold the minutes value
    reg [5:0] hours_reg; // Register to hold the hours value

    // Always block for updating seconds
    always @(posedge CLK or posedge RST) begin
        if (RST) begin
            secs_reg <= 6'b000000; // Reset seconds to 0
        end else if (secs_reg == 6'd59) begin
            secs_reg <= 6'b000000; // Wrap around seconds to 0 when it reaches 59
        end else begin
            secs_reg <= secs_reg + 1; // Increment seconds by 1
        end
    end

    // Always block for updating minutes
    always @(posedge CLK or posedge RST) begin
        if (RST) begin
            mins_reg <= 6'b000000; // Reset minutes to 0
        end else if (secs_reg == 6'd59 && mins_reg == 6'd59) begin
            mins_reg <= 6'b000000; // Wrap around minutes to 0 when both secs and mins are 59
        end else if (secs_reg == 6'd59) begin
            mins_reg <= mins_reg + 1; // Increment minutes by 1 when seconds reach 59
        end
    end

    // Always block for updating hours
    always @(posedge CLK or posedge RST) begin
        if (RST) begin
            hours_reg <= 6'b000000; // Reset hours to 0
        end else if (hours_reg == 6'd23 && mins_reg == 6'd59 && secs_reg == 6'd59) begin
            hours_reg <= 6'b000000; // Wrap around hours to 0 when all reach their maximum
        end else if (mins_reg == 6'd59 && secs_reg == 6'd59) begin
            hours_reg <= hours_reg + 1; // Increment hours by 1 when minutes and seconds reach 59
        end
    end

    // Assign the register values to the output ports
    assign Hours = hours_reg;
    assign Mins = mins_reg;
    assign Secs = secs_reg;

endmodule