module calendar (
    input wire CLK,        // Clock input
    input wire RST,        // Active high reset signal
    output reg [5:0] Hours, // 6-bit output representing the current hours
    output reg [5:0] Mins,  // 6-bit output representing the current minutes
    output reg [5:0] Secs   // 6-bit output representing the current seconds
);

    // Always block to update seconds
    always @(posedge CLK or posedge RST) begin
        if (RST) begin
            Secs <= 6'b000000; // Reset seconds to 0
        end else if (Secs == 6'b111011) begin // If seconds are 59
            Secs <= 6'b000000; // Wrap around to 0
        end else begin
            Secs <= Secs + 1; // Increment seconds
        end
    end

    // Always block to update minutes
    always @(posedge CLK or posedge RST) begin
        if (RST) begin
            Mins <= 6'b000000; // Reset minutes to 0
        end else if (Mins == 6'b111011 && Secs == 6'b111011) begin // If minutes and seconds are 59
            Mins <= 6'b000000; // Wrap around to 0
        end else if (Secs == 6'b111011) begin // If seconds are 59
            Mins <= Mins + 1; // Increment minutes
        end
    end

    // Always block to update hours
    always @(posedge CLK or posedge RST) begin
        if (RST) begin
            Hours <= 6'b000000; // Reset hours to 0
        end else if (Hours == 6'b010111 && Mins == 6'b111011 && Secs == 6'b111011) begin // If hours, minutes, and seconds are 23, 59, and 59
            Hours <= 6'b000000; // Wrap around to 0
        end else if (Mins == 6'b111011 && Secs == 6'b111011) begin // If minutes and seconds are 59
            Hours <= Hours + 1; // Increment hours
        end
    end

endmodule