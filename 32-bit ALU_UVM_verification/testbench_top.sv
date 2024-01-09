module testbench_top;

import uvm_pkg::*;
import my_uvm_package::*;


alu_if _if();


ALU arithmetic_logic_unit(

.in1(_if.in1),
.in2(_if.in2),
.ALUControl(_if.ALUControl),

.ALUResult(_if.ALUResult),
.zero(_if.zero)

);



initial begin
uvm_config_db#(virtual alu_if)::set(null,"*","virtual_interface",_if);
run_test("test1");
end











endmodule
