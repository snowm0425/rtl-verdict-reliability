module calendar (
    input CLK,      // Clock input
    input RST,      // Active high reset signal
    output [5:0] Hours, // 6-bit output representing the current hours (0-23)
    output [5:0] Mins,  // 6-bit output representing the current minutes (0-59)
    output [5:0] Secs   // 6-bit output representing the current seconds (0-59)
);

    reg [5:0] secs_reg;
    reg [5:0] mins_reg;
    reg [5:0] hours_reg;

    // Seconds counter
    always @(posedge CLK or posedge RST) begin
        if (RST) begin
            secs_reg <= 6'b000000;
        end else begin
            if (secs_reg == 6'd59) begin
                secs_reg <= 6'b000000;
            end else begin
                secs_reg <= secs_reg + 1;
            end
        end
    end

    // Minutes counter
    always @(posedge CLK or posedge RST) begin
        if (RST) begin
            mins_reg <= 6'b000000;
        end else begin
            if (secs_reg == 6'd59 && mins_reg == 6'd59) begin
                mins_reg <= 6'b000000;
            end else if (secs_reg == 6'd59) begin
                mins_reg <= mins_reg + 1;
            end
        end
    end

    // Hours counter
    always @(posedge CLK or posedge RST) begin
        if (RST) begin
            hours_reg <= 6'b000000;
        end else begin
            if (hours_reg == 6'd23 && mins_reg == 6'd59 && secs_reg == 6'd59) begin
                hours_reg <= 6'b000000;
            end else if (mins_reg == 6'd59 && secs_reg == 6'd59) begin
                hours_reg <= hours_reg + 1;
            end
        end
    end

    // Assign the register values to the output ports
    assign Hours = hours_reg;
    assign Mins = mins_reg;
    assign Secs = secs_reg;

endmodule