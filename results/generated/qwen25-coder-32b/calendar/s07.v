module calendar (
    input wire CLK,       // Clock input
    input wire RST,       // Active high reset signal
    output reg [5:0] Hours, // 6-bit output representing the current hours (0-23)
    output reg [5:0] Mins,  // 6-bit output representing the current minutes (0-59)
    output reg [5:0] Secs   // 6-bit output representing the current seconds (0-59)
);

// Always block to update seconds
always @(posedge CLK or posedge RST) begin
    if (RST) begin
        Secs <= 6'b000000; // Reset seconds to 0
    end else if (Secs == 6'd59) begin
        Secs <= 6'b000000; // Wrap around to 0 when seconds reach 59
    end else begin
        Secs <= Secs + 1; // Increment seconds by 1
    end
end

// Always block to update minutes
always @(posedge CLK or posedge RST) begin
    if (RST) begin
        Mins <= 6'b000000; // Reset minutes to 0
    end else if (Secs == 6'd59 && Mins == 6'd59) begin
        Mins <= 6'b000000; // Wrap around to 0 when both seconds and minutes reach 59
    end else if (Secs == 6'd59) begin
        Mins <= Mins + 1; // Increment minutes by 1 when seconds reach 59
    end
end

// Always block to update hours
always @(posedge CLK or posedge RST) begin
    if (RST) begin
        Hours <= 6'b000000; // Reset hours to 0
    end else if (Hours == 6'd23 && Mins == 6'd59 && Secs == 6'd59) begin
        Hours <= 6'b000000; // Wrap around to 0 when hours, minutes, and seconds reach their max
    end else if (Mins == 6'd59 && Secs == 6'd59) begin
        Hours <= Hours + 1; // Increment hours by 1 when minutes and seconds reach 59
    end
end

endmodule