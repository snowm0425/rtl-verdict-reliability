module freq_div (
    input wire CLK_in,    // Input clock signal (100MHz)
    input wire RST,       // Reset signal (active high)
    output reg CLK_50,    // Output clock signal (50MHz)
    output reg CLK_10,    // Output clock signal (10MHz)
    output reg CLK_1      // Output clock signal (1MHz)
);

    // Counters for frequency division
    reg [2:0] cnt_10;  // Counter for 10MHz division (0 to 4)
    reg [5:0] cnt_100; // Counter for 1MHz division (0 to 49)

    // CLK_50 generation
    always @(posedge CLK_in or posedge RST) begin
        if (RST) begin
            CLK_50 <= 0;
        end else begin
            CLK_50 <= ~CLK_50;  // Toggle CLK_50 on every rising edge of CLK_in
        end
    end

    // CLK_10 generation
    always @(posedge CLK_in or posedge RST) begin
        if (RST) begin
            CLK_10 <= 0;
            cnt_10 <= 0;
        end else begin
            if (cnt_10 == 4) begin
                CLK_10 <= ~CLK_10;  // Toggle CLK_10 when cnt_10 reaches 4
                cnt_10 <= 0;        // Reset cnt_10
            end else begin
                cnt_10 <= cnt_10 + 1;  // Increment cnt_10
            end
        end
    end

    // CLK_1 generation
    always @(posedge CLK_in or posedge RST) begin
        if (RST) begin
            CLK_1 <= 0;
            cnt_100 <= 0;
        end else begin
            if (cnt_100 == 49) begin
                CLK_1 <= ~CLK_1;  // Toggle CLK_1 when cnt_100 reaches 49
                cnt_100 <= 0;     // Reset cnt_100
            end else begin
                cnt_100 <= cnt_100 + 1;  // Increment cnt_100
            end
        end
    end

endmodule