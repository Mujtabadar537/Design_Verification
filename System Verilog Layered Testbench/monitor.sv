`include "transaction.sv"

class monitor;

  virtual dut_if vif_monitor;
  mailbox mon2scb;
  transaction tx;

  function new(virtual dut_if vif_monitor, mailbox mon2scb);
    this.vif_monitor = vif_monitor;
    this.mon2scb = mon2scb;
  endfunction 

  task main;
    repeat (20) begin
      #5;
      tx = new();

      tx.in1 = vif_monitor.in1;
      tx.in2 = vif_monitor.in2;
      tx.cin = vif_monitor.cin;
      tx.sum = vif_monitor.sum;
      tx.carry = vif_monitor.carry;

      mon2scb.put(tx);
      tx.display("MONITOR CLASS");
    end
  endtask

endclass

