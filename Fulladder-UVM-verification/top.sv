/** Author : Mujtaba Waseem **/
/** Institute : UET Lahore **/


module top;

import uvm_pkg::*;
import uvmpackage::*;

dut_if dut_if1();

dut adder(

.in1(dut_if1.in1),
.in2(dut_if1.in2),
.cin(dut_if1.cin),
.sum(dut_if1.sum),
.cout(dut_if1.cout)

);

initial begin
uvm_config_db #(virtual dut_if)::set(null , "*" , "virtual_interface" , dut_if1);//set(caller , path , name ,value)
run_test("test1");
end



endmodule
