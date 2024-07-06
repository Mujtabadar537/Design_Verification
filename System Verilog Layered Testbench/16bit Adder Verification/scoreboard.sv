`include "transaction.sv"

class scoreboard;

mailbox mon2scb;




function new(mailbox mon2scb);
	this.mon2scb = mon2scb;
endfunction



task main();
transaction tx;
	repeat(20) begin
		mon2scb.get(tx);
		tx.display("SCOREBOARD CLASS");
		if({tx.carry , tx.sum} == (tx.in1 + tx.in2 + tx.cin))
			$display("TEST PASSED");

		else begin
			$display("TEST FAILED");
		end

	end
endtask






endclass
