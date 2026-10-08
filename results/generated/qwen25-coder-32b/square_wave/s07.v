module square_wave (
    input clk,          // Clock signal that drives the module
    input [7:0] freq,   // Frequency control, specifying how often the square wave toggles
    output reg wave_out // Square wave output signal
);

    reg [7:0] count;    // Counter register used to track cycles between wave toggles

    always @(posedge clk) begin
        if (count == (freq - 1)) begin
            count <= 0;         // Reset count to 0
            wave_out <= ~wave_out; // Toggle wave_out
        end else begin
            count <= count + 1; // Increment count
        end
    end

endmodule