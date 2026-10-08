module calendar (
    input wire CLK,          // Clock input
    input wire RST,          // Active high reset signal
    output reg [5:0] Hours,  // 6-bit output representing the current hours (0-23)
    output reg [5:0] Mins,   // 6-bit output representing the current minutes (0-59)
    output reg [5:0] Secs    // 6-bit output representing the current seconds (0-59)
);

// Always block to update seconds
always @(posedge CLK or posedge RST) begin
    if (RST) begin
        Secs <= 6'b000000;  // Reset seconds to 0
    end else begin
        if (Secs == 6'd59) begin
            Secs <= 6'b000000;  // Wrap around seconds to 0 when it reaches 59
        end else begin
            Secs <= Secs + 1;  // Increment seconds by 1
        end
    end
end

// Always block to update minutes
always @(posedge CLK or posedge RST) begin
    if (RST) begin
        Mins <= 6'b000000;  // Reset minutes to 0
    end else if (Secs == 6'd59) begin
        if (Mins == 6'd59) begin
            Mins <= 6'b000000;  // Wrap around minutes to 0 when it reaches 59
        end else begin
            Mins <= Mins + 1;  // Increment minutes by 1
        end
    end
end

// Always block to update hours
always @(posedge CLK or posedge RST) begin
    if (RST) begin
        Hours <= 6'b000000;  // Reset hours to 0
    end else if (Mins == 6'd59 && Secs == 6'd59) begin
        if (Hours == 6'd23) begin
            Hours <= 6'b000000;  // Wrap around hours to 0 when it reaches 23
        end else begin
            Hours <= Hours + 1;  // Increment hours by 1
        end
    end
end

endmodule