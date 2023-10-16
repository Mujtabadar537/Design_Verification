/** Author : Mujtaba Waseem **/
/** Institute : UET Lahore **/


module top;

import uvm_pkg::*;
import uvmpackage::*;

dut_if dut_if1();//instance of interface

//connecting dut with interface
dut dflipflop(

.clk(dut_if1.clk),
.reset(dut_if1.reset),
.d(dut_if1.d),

.q(dut_if1.q),
.qbar(dut_if1.qbar)

);



initial begin
dut_if1.clk = 0;
uvm_config_db #(virtual dut_if)::set(null,"*","virtual_interface",dut_if1);
run_test("test1");

end

always #30 dut_if1.clk = ~dut_if1.clk;







endmodule
