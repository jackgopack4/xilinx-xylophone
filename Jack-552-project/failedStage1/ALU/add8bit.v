module add8bit(cout, sum, a, b, cin);
    output [7:0] sum;
    output cout;
    input cin;
    input [7:0] a, b;

    wire cout0, cout1, cout2, cout3, cout4, cout5, cout6;

    FA A0(cout0, sum[0], a[0], b[0], cin);
    FA A1(cout1, sum[1], a[1], b[1], cout0);
    FA A2(cout2, sum[2], a[2], b[2], cout1);
    FA A3(cout3, sum[3], a[3], b[3], cout2);
    FA A4(cout4, sum[4], a[4], b[4], cout3);
    FA A5(cout5, sum[5], a[5], b[5], cout4);
    FA A6(cout6, sum[6], a[6], b[6], cout5);
    FA A7(cout, sum[7], a[7], b[7], cout6);
    
endmodule

