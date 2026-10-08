module multi_16bit (
    input  wire        clk,
    input  wire        rst_n,
    input  wire        start,
    input  wire [15:0] ain,
    input  wire [15:0] bin,
    output wire [31:0] yout,
    output wire        done
);

    // Internal registers
    reg [4:0]  i;          // Shift count register, 5 bits to hold values 0-17
    reg        done_r;     // Completion flag register
    reg [15:0] areg;       // Multiplicand register
    reg [15:0] breg;       // Multiplier register
    reg [31:0] yout_r;     // Product register

    // Output assignments
    assign yout = yout_r;
    assign done = done_r;

    // Shift count register (i)
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            i <= 5'd0;
        end else if (start && i < 5'd17) begin
            i <= i + 5'd1;
        end else if (!start) begin
            i <= 5'd0;
        end
    end

    // Completion flag generation
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            done_r <= 1'b0;
        end else if (i == 5'd16) begin
            done_r <= 1'b1;
        end else if (i == 5'd17) begin
            done_r <= 1'b0;
        end
    end

    // Shift and accumulate operation
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            areg   <= 16'd0;
            breg   <= 16'd0;
            yout_r <= 32'd0;
        end else if (start) begin
            if (i == 5'd0) begin
                // Store inputs
                areg   <= ain;
                breg   <= bin;
                yout_r <= 32'd0;
            end else if (i > 5'd0 && i < 5'd17) begin
                // Accumulate if the bit at position i-1 in areg is high
                if (areg[i-1]) begin
                    yout_r <= yout_r + ({breg, 16'd0} << (i - 1));
                end else begin
                    yout_r <= yout_r;
                end
            end
        end else begin
            // When start is inactive, reset registers (optional, but consistent with i reset)
            areg   <= 16'd0;
            breg   <= 16'd0;
            yout_r <= 32'd0;
        end
    end

endmodule