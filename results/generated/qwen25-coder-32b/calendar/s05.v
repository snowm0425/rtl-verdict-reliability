module calendar (
    input wire CLK,          // Clock input
    input wire RST,          // Active high reset signal
    output reg [5:0] Hours,  // 6-bit output representing the current hours (0-23)
    output reg [5:0] Mins,   // 6-bit output representing the current minutes (0-59)
    output reg [5:0] Secs    // 6-bit output representing the current seconds (0-59)
);

always @(posedge CLK or posedge RST) begin
    if (RST) begin
        Secs <= 6'b000000;  // Reset seconds to 0
    end else if (Secs == 6'b111011) begin  // If seconds are 59
        Secs <= 6'b000000;  // Wrap around to 0
    end else begin
        Secs <= Secs + 1;   // Increment seconds by 1
    end
end

always @(posedge CLK or posedge RST) begin
    if (RST) begin
        Mins <= 6'b000000;  // Reset minutes to 0
    end else if (Mins == 6'b111011 && Secs == 6'b111011) begin  // If minutes are 59 and seconds are 59
        Mins <= 6'b000000;  // Wrap around to 0
    end else if (Secs == 6'b111011) begin  // If seconds are 59
        Mins <= Mins + 1;   // Increment minutes by 1
    end
end

always @(posedge CLK or posedge RST) begin
    if (RST) begin
        Hours <= 6'b000000;  // Reset hours to 0
    end else if (Hours == 6'b010111 && Mins == 6'b111011 && Secs == 6'b111011) begin  // If hours are 23, minutes are 59, and seconds are 59
        Hours <= 6'b000000;  // Wrap around to 0
    end else if (Mins == 6'b111011 && Secs == 6'b111011) begin  // If minutes are 59 and seconds are 59
        Hours <= Hours + 1;  // Increment hours by 1
    end
end

endmodule