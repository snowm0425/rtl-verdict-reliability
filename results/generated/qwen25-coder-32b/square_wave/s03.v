module square_wave (
    input wire clk,          // Clock signal
    input wire [7:0] freq,   // Frequency control (8-bit)
    output reg wave_out      // Square wave output
);

    // Internal register to count clock cycles
    reg [7:0] count;

    // Always block to handle the clock edge
    always @(posedge clk) begin
        if (count == freq - 1) begin
            // Reset counter and toggle wave_out
            count <= 0;
            wave_out <= ~wave_out;
        end else begin
            // Increment counter
            count <= count + 1;
        end
    end

endmodule