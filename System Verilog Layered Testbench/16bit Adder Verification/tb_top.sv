`include "dut_if.sv"
`include "test.sv"


module tb_top;

dut_if _if();

test test1(_if);

full_adder FA(

.in1(_if.in1),
.in2(_if.in2),
.cin(_if.cin),
.sum(_if.sum),
.carry(_if.carry)

);

endmodule
