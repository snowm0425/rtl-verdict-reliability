module calendar (
    input wire CLK,        // Clock input
    input wire RST,        // Active high reset signal
    output reg [5:0] Hours, // 6-bit output representing the current hours
    output reg [5:0] Mins,  // 6-bit output representing the current minutes
    output reg [5:0] Secs   // 6-bit output representing the current seconds
);

// Internal registers for Seconds, Minutes, and Hours
reg [5:0] sec_reg;
reg [5:0] min_reg;
reg [5:0] hour_reg;

// Always block for Seconds
always @(posedge CLK or posedge RST) begin
    if (RST) begin
        sec_reg <= 6'b000000; // Reset Seconds to 0
    end else if (sec_reg == 6'd59) begin
        sec_reg <= 6'b000000; // Wrap around Seconds to 0
    end else begin
        sec_reg <= sec_reg + 1; // Increment Seconds by 1
    end
end

// Always block for Minutes
always @(posedge CLK or posedge RST) begin
    if (RST) begin
        min_reg <= 6'b000000; // Reset Minutes to 0
    end else if (sec_reg == 6'd59 && min_reg == 6'd59) begin
        min_reg <= 6'b000000; // Wrap around Minutes to 0
    end else if (sec_reg == 6'd59) begin
        min_reg <= min_reg + 1; // Increment Minutes by 1
    end
end

// Always block for Hours
always @(posedge CLK or posedge RST) begin
    if (RST) begin
        hour_reg <= 6'b000000; // Reset Hours to 0
    end else if (hour_reg == 6'd23 && min_reg == 6'd59 && sec_reg == 6'd59) begin
        hour_reg <= 6'b000000; // Wrap around Hours to 0
    end else if (min_reg == 6'd59 && sec_reg == 6'd59) begin
        hour_reg <= hour_reg + 1; // Increment Hours by 1
    end
end

// Assign internal registers to output ports
assign Hours = hour_reg;
assign Mins = min_reg;
assign Secs = sec_reg;

endmodule