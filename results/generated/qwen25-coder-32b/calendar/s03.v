module calendar (
    input CLK,        // Clock input
    input RST,        // Active high reset signal
    output reg [5:0] Hours, // 6-bit output representing the current hours
    output reg [5:0] Mins,  // 6-bit output representing the current minutes
    output reg [5:0] Secs   // 6-bit output representing the current seconds
);

always @(posedge CLK or posedge RST) begin
    if (RST) begin
        Secs <= 6'b000000; // Reset seconds to 0
    end else begin
        if (Secs == 6'd59) begin
            Secs <= 6'b000000; // Wrap around seconds to 0
        end else begin
            Secs <= Secs + 1; // Increment seconds
        end
    end
end

always @(posedge CLK or posedge RST) begin
    if (RST) begin
        Mins <= 6'b000000; // Reset minutes to 0
    end else begin
        if (Secs == 6'd59 && Mins == 6'd59) begin
            Mins <= 6'b000000; // Wrap around minutes to 0
        end else if (Secs == 6'd59) begin
            Mins <= Mins + 1; // Increment minutes
        end
        // Else, keep minutes unchanged
    end
end

always @(posedge CLK or posedge RST) begin
    if (RST) begin
        Hours <= 6'b000000; // Reset hours to 0
    end else begin
        if (Hours == 6'd23 && Mins == 6'd59 && Secs == 6'd59) begin
            Hours <= 6'b000000; // Wrap around hours to 0
        end else if (Mins == 6'd59 && Secs == 6'd59) begin
            Hours <= Hours + 1; // Increment hours
        end
        // Else, keep hours unchanged
    end
end

endmodule