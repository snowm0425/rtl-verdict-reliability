module freq_div (
    input wire CLK_in,  // Input clock signal of 100MHz
    input wire RST,     // Active high reset signal
    output reg CLK_50,  // Output clock signal of 50MHz
    output reg CLK_10,  // Output clock signal of 10MHz
    output reg CLK_1    // Output clock signal of 1MHz
);

    // Counters for CLK_10 and CLK_1 generation
    reg [3:0] cnt_10;  // 4-bit counter for 10MHz division
    reg [5:0] cnt_100; // 6-bit counter for 1MHz division

    // Sequential logic to generate CLK_50
    always @(posedge CLK_in or posedge RST) begin
        if (RST) begin
            CLK_50 <= 0;
        end else begin
            CLK_50 <= ~CLK_50; // Toggle CLK_50 on each rising edge of CLK_in
        end
    end

    // Sequential logic to generate CLK_10
    always @(posedge CLK_in or posedge RST) begin
        if (RST) begin
            CLK_10 <= 0;
            cnt_10 <= 4'b0; // Reset counter to 0
        end else begin
            if (cnt_10 == 4'd4) begin // When counter reaches 4
                CLK_10 <= ~CLK_10; // Toggle CLK_10
                cnt_10 <= 4'b0;     // Reset counter to 0
            end else begin
                cnt_10 <= cnt_10 + 1; // Increment counter
            end
        end
    end

    // Sequential logic to generate CLK_1
    always @(posedge CLK_in or posedge RST) begin
        if (RST) begin
            CLK_1 <= 0;
            cnt_100 <= 6'b0; // Reset counter to 0
        end else begin
            if (cnt_100 == 6'd49) begin // When counter reaches 49
                CLK_1 <= ~CLK_1; // Toggle CLK_1
                cnt_100 <= 6'b0;   // Reset counter to 0
            end else begin
                cnt_100 <= cnt_100 + 1; // Increment counter
            end
        end
    end

endmodule