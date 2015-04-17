module logicmod(Out, Z, A, B, Sel);

  input [15:0] A, B;
  input Sel;
  output [15:0] Out;
  output Z;

  wire [15:0] andwire, norwire;

  assign andwire = (A & B);
  //always@(andwire && !Sel) $display("And result = %b", andwire);
  assign norwire = ~(A | B);
  assign Out = (Sel) ? norwire : andwire;
  assign Z = (Out == 16'h0000);

endmodule
