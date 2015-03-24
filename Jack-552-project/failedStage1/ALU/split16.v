module split16(Out, In);
input In;
output [15:0] Out;
assign Out = {In, In, In, In, In, In, In, In, In, In, In, In, In, In, In, In};
endmodule
