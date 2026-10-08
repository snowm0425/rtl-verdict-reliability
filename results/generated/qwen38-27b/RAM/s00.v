module RAM (
    input  wire        clk,
    input  wire        rst_n,
    input  wire        write_en,
    input  wire [2:0]  write_addr,  // log2(8) = 3 bits
    input  wire [5:0]  write_data,
    input  wire        read_en,
    input  wire [2:0]  read_addr,   // log2(8) = 3 bits
    output reg  [5:0]  read_data
);

    parameter WIDTH = 6;
    parameter DEPTH = 8;

    // RAM array: DEPTH locations, each WIDTH bits wide
    reg [WIDTH-1:0] RAM [0:DEPTH-1];

    // Initialize RAM to 0 on reset
    integer i;
    initial begin
        for (i = 0; i < DEPTH; i = i + 1)
            RAM[i] = {WIDTH{1'b0}};
    end

    // Write operation
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            for (i = 0; i < DEPTH; i = i + 1)
                RAM[i] <= {WIDTH{1'b0}};
        end else if (write_en) begin
            RAM[write_addr] <= write_data;
        end
    end

    // Read operation
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            read_data <= {WIDTH{1'b0}};
        end else if (read_en) begin
            read_data <= RAM[read_addr];
        end else begin
            read_data <= {WIDTH{1'b0}};
        end
    end

endmodule