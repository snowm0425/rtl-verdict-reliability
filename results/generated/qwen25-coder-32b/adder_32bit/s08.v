module testbench;
    reg [31:0] A;
    reg [31:0] B;
    reg cin;
    wire [31:0] S;
    wire cout;

    adder_32bit adder (
        .A(A),
        .B(B),
        .cin(cin),
        .S(S),
        .cout(cout)
    );

    initial begin
        // Test case 1
        A = 32'd4294967295; // 0xFFFFFFFF
        B = 32'd1;          // 0x00000001
        cin = 1'b0;
        #10;

        // Test case 2
        A = 32'd123456789;
        B = 32'd987654321;
        cin = 1'b0;
        #10;

        // Test case 3
        A = 32'd0;
        B = 32'd0;
        cin = 1'b1;
        #10;

        $finish;
    end

    initial begin
        $monitor("A = %h, B = %h, cin = %b, S = %h, cout = %b", A, B, cin, S, cout);
    end
endmodule