`include "environment.sv"

program test(dut_if _if);

environment env;

initial begin
	env = new(_if);
	env.run_test();
end

endprogram
