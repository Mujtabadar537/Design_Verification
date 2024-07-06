`include "transaction.sv"

class driver;

virtual dut_if vif_driver;


mailbox gen2driver;

function new(virtual dut_if vif_driver , mailbox gen2driver);
	this.gen2driver = gen2driver;
	this.vif_driver = vif_driver;
endfunction 



task main();

	repeat(20) begin
		transaction tx;
		gen2driver.get(tx);

		vif_driver.in1 <= tx.in1;
		vif_driver.in2 <= tx.in2;
		vif_driver.cin <= tx.cin;

		
		tx.sum = vif_driver.sum;
		tx.carry = vif_driver.carry;

		#5;
		

		tx.display("DRIVER CLASS");
	end


endtask



endclass
