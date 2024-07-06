module full_adder(

input [15:0]in1,
input [15:0]in2,
input cin,

output logic [15:0]sum,
output logic carry

);


assign {carry , sum} = in1 + in2 + cin;


endmodule

