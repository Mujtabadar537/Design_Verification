module dut(

input logic in1,
input logic in2,
input logic cin,

output logic sum,
output logic cout


);


always_comb begin

sum = in1 ^ in2 ^ cin;
cout = (in1 & in2) | (in2 & cin) | (cin & in1);

end


endmodule
