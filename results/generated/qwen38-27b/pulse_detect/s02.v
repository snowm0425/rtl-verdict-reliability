module pulse_detect (
    input wire clk,
    input wire rst_n,
    input wire data_in,
    output reg data_out
);

    // Register to store the previous two states of data_in
    // prev_data[0] holds data_in from the previous clock cycle
    // prev_data[1] holds data_in from the clock cycle before that
    reg [1:0] prev_data;

    // Synchronous reset, active low
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            data_out <= 1'b0;
            prev_data <= 2'b00;
        end
        else begin
            // Update the history register
            // Shift in the current data_in
            prev_data[1] <= prev_data[0];
            prev_data[0] <= data_in;

            // Check for the pattern: 0 -> 1 -> 0
            // Current data_in is 0
            // Previous data_in (prev_data[0]) was 1
            // Previous-1 data_in (prev_data[1]) was 0
            if (data_in == 1'b0 && prev_data[0] == 1'b1 && prev_data[1] == 1'b0) begin
                data_out <= 1'b1;
            end
            else begin
                data_out <= 1'b0;
            end
        end
    end

endmodule