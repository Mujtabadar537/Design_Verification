import uvm_pkg::*;
import uvm_architecture::*;
`include "uvm_macros.svh"

module uvm_testbench_top;


logic clk;
logic reset;



design_interface dut_if(.clk(clk) , .reset(reset));


initial begin
   clk = 0;
   forever #20 clk = ~clk;
end


initial begin
   reset = 1;
   #50
   reset = 0;
end


sequence_detector DUT(

.clk(clk),
.reset(reset),
.in(dut_if.in),
.out(dut_if.out)

);


initial begin
   uvm_config_db#(virtual design_interface)::set(null , "*" , "vif" , dut_if);
   run_test("test1");
end







endmodule
