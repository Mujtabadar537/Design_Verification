package uvm_architecture;

import uvm_pkg::*;
`include "uvm_macros.svh"


//***************[SEQUENCE ITEM CLASS]*******************
class sequence_item extends uvm_sequence_item;


rand logic in;
logic out;


`uvm_object_utils_begin(sequence_item)

`uvm_field_int(in , UVM_DEFAULT + UVM_HEX)
`uvm_field_int(out , UVM_DEFAULT + UVM_HEX)

`uvm_object_utils_end


function new(string name = "sequence_item");
    super.new(name);
endfunction


function void display_pkt();
    `uvm_info(get_type_name() , $sformatf("in = %0h , out = %0h" , in , out) , UVM_NONE);
endfunction



endclass


//*******************************************************




//***************[SEQUENCE ITEM CLASS]*******************

class sequence1 extends uvm_sequence;

`uvm_object_utils(sequence1)


sequence_item pkt;


function new(string name = "sequence1");
     super.new(name);
endfunction


virtual task body();

    req = sequence_item::type_id::create("req");
    repeat(30) begin

       start_item(req);
	  req.randomize;
       finish_item(req);

    end

endtask


endclass



//*******************************************************




//*******************[SEQUENCER CLASS]*******************

class sequencer extends uvm_sequencer #(sequence_item);

`uvm_component_utils(sequencer)

function new(string name = "sequencer" , uvm_component parent);
super.new(name , parent);
endfunction

endclass


//*******************************************************





//**********************[DRIVER CLASS]*******************

class driver extends uvm_driver#(sequence_item);

`uvm_component_utils(driver)

//virtual interface handle
virtual design_interface vif_driver;

//sequence_item pkt;

function new(string name = "driver" , uvm_component parent = null);
    super.new(name , parent);
endfunction


function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    //pkt = sequence_item::type_id::create("pkt");
    req = sequence_item::type_id::create("req");

    if(!uvm_config_db#(virtual design_interface)::get(this , "" , "vif" , vif_driver))
      `uvm_fatal(get_type_name() , "FAILED TO GET VIRTUAL INTERFACE")

    else `uvm_info(get_type_name() , "VIRTUAL INTERFACE RECIEVED" , UVM_NONE)

endfunction




virtual task run_phase(uvm_phase phase);

super.run_phase(phase);

forever begin

  //sequence_item pkt;

  seq_item_port.get_next_item(req);
  drive_pkt(req);
  seq_item_port.item_done();


end

endtask



//driving the sequence
virtual task drive_pkt(sequence_item pkt);


vif_driver.in <= pkt.in;
//vif_driver.out <= pkt.out;
//`uvm_info(get_type_name() , $sformatf("Driver sampled: in = %0h", pkt.in), UVM_NONE);
@(posedge vif_driver.clk);

endtask


endclass


//*******************************************************




//*********************[MONITOR CLASS]*******************

class monitor extends uvm_monitor;

`uvm_component_utils(monitor)


//virtual interface handle
virtual design_interface vif_monitor;


sequence_item pkt;


//analysis port 
uvm_analysis_port #(sequence_item) analysis_port;


function new(string name = "monitor" , uvm_component parent = null);
     super.new(name , parent);
endfunction



function void build_phase(uvm_phase phase);
    super.build_phase(phase);

    //creating analysis port
    analysis_port = new("analysis_port" , this);

    pkt = sequence_item::type_id::create("pkt");

    if(!uvm_config_db#(virtual design_interface)::get(this , "" , "vif" , vif_monitor))
      `uvm_fatal(get_type_name() , "FAILED TO GET VIRTUAL INTERFACE")

    else `uvm_info(get_type_name() , "VIRTUAL INTERFACE RECIEVED" , UVM_NONE)

endfunction



virtual task run_phase(uvm_phase phase);

forever begin

  @(posedge vif_monitor.clk);
  //`uvm_info("MONITOR", $sformatf("Monitor sampled: in = %0h, out = %0h", vif_monitor.in, vif_monitor.out), UVM_LOW);
  pkt.in <= vif_monitor.in;
  pkt.out <= vif_monitor.out;
  analysis_port.write(pkt);
  
end

endtask



endclass



//*******************************************************





//******************[SCOREBOARD CLASS]*******************


class scoreboard extends uvm_scoreboard;

`uvm_component_utils(scoreboard)

sequence_item pkt_queue[$];

sequence_item pkt;


//analysis implementation port
uvm_analysis_imp #(sequence_item , scoreboard) analysis_imp;


function new(string name = "scoreboard" , uvm_component parent = null);
    super.new(name , parent);
    analysis_imp = new("analysis_imp" , this);
endfunction

function void build_phase(uvm_phase phase);
    super.build_phase(phase);
endfunction

virtual function write(sequence_item pkt);
    pkt_queue.push_back(pkt);
endfunction

task run_phase(uvm_phase phase);

    logic [3:0] shift_reg = 4'b0000; 
    logic expected_output;

    forever begin
        wait(pkt_queue.size > 0);

        if (pkt_queue.size > 0) begin
            pkt = pkt_queue.pop_front();
            shift_reg = {shift_reg[2:0], pkt.in};
            `uvm_info(get_type_name(), $sformatf("[%0t]Shift Register = %0b", $time , shift_reg), UVM_NONE);
            expected_output = (shift_reg == 4'b1011) ? 1'b1 : 1'b0;

            #40;

            if (expected_output == pkt.out) begin
                 if(expected_output == 1'b1 && shift_reg == 4'b1011) begin
                    `uvm_info(get_type_name(), $sformatf("[%0t]SEQUENCE DETECTED , TEST PASSED SUCCESSFULLY",$time) , UVM_NONE);
		 end
                 else begin
                    `uvm_info(get_type_name(), $sformatf("[%0t]OUTPUTS MATCHED",$time),UVM_NONE);
                    `uvm_info(get_type_name(), $sformatf("[%0t]Expected Output = %0h, Actual Output = %0h", $time , expected_output, pkt.out), UVM_NONE);
	         end
                 $display("\n");
            end else begin
                `uvm_error(get_type_name(), $sformatf("[%0t]OUTPUTS MISMATCHED, TEST FAILED",$time));
                `uvm_info(get_type_name(), $sformatf("[%0t]Expected Output = %0h, Actual Output = %0h", $time , expected_output, pkt.out), UVM_NONE);
                 $display("\n");
            end
        end
    end
endtask

endclass



//*******************************************************




//***********************[AGENT CLASS]*******************

class agent extends uvm_agent;

`uvm_component_utils(agent)

sequencer seqr;
driver drv;
monitor mon;



virtual design_interface vif_agent1;


function new(string name = "agent" , uvm_component parent = null);
     super.new(name , parent);
endfunction



function void build_phase(uvm_phase phase);
     super.build_phase(phase);
     seqr = sequencer::type_id::create("seqr",this);
     drv = driver::type_id::create("drv",this);
     mon = monitor::type_id::create("mon",this);

    if(!uvm_config_db#(virtual design_interface)::get(this , "" , "vif" , vif_agent1))
      `uvm_fatal(get_type_name() , "FAILED TO GET VIRTUAL INTERFACE");

endfunction



function void connect_phase(uvm_phase phase);
     super.connect_phase(phase);
     drv.seq_item_port.connect(seqr.seq_item_export);
endfunction



endclass



//*******************************************************




//*****************[ENVIRONMENT CLASS]*******************

class environment extends uvm_env;

`uvm_component_utils(environment)


agent agent1;
scoreboard scb;


function new(string name = "environment" , uvm_component parent = null);
     super.new(name , parent);
endfunction



function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      agent1 = agent::type_id::create("agent1",this);
      scb = scoreboard::type_id::create("scb",this);
endfunction



function void connect_phase(uvm_phase phase);
       super.connect_phase(phase);
       agent1.mon.analysis_port.connect(scb.analysis_imp);
endfunction


endclass

//*******************************************************




//************************[TEST CLASS]*******************

class base_test extends uvm_test;

`uvm_component_utils(base_test)

environment env;


function new(string name = "base_test" , uvm_component parent);
super.new(name,parent);
endfunction



function void build_phase(uvm_phase phase);
super.build_phase(phase);

env = environment::type_id::create("env",this);

endfunction



function void end_of_elaboration_phase(uvm_phase phase);
super.end_of_elaboration_phase(phase);
uvm_top.print_topology();
endfunction



/**function void report_phase(uvm_phase phase);

uvm_report_server server;

super.report_phase(phase);

server = uvm_report_server::get_server();

if(server.get_severity_count(UVM_FATAL) == 0 & server.get_severity_count(UVM_ERROR) == 0) begin

`uvm_info("REPORT PHASE","--------------------------------",UVM_NONE);
`uvm_info("REPORT PHASE","-----------TEST1 PASSED----------",UVM_NONE);
`uvm_info("REPORT PHASE","--------------------------------",UVM_NONE);

if(server.get_severity_count(UVM_WARNING) != 0) begin


`uvm_info("REPORT PHASE","--------------------------------",UVM_NONE);
`uvm_info("REPORT PHASE","-----------WARNING!!!!!!!----------",UVM_NONE);
`uvm_info("REPORT PHASE","--------------------------------",UVM_NONE);

end

if(server.get_severity_count(UVM_FATAL) != 0) begin


`uvm_info("REPORT PHASE","--------------------------------",UVM_NONE);
`uvm_info("REPORT PHASE","-----------FATAL ERROR!!!!!!!----------",UVM_NONE);
`uvm_info("REPORT PHASE","--------------------------------",UVM_NONE);

end




end

else begin

`uvm_info("REPORT PHASE","--------------------------------",UVM_NONE);
`uvm_info("REPORT PHASE","-----------TEST1 FAILED----------",UVM_NONE);
`uvm_info("REPORT PHASE","--------------------------------",UVM_NONE);

end


endfunction**/




endclass



class test1 extends base_test;

`uvm_component_utils(test1)

sequence1 seq;


function new(string name = "test1" , uvm_component parent);
super.new(name,parent);
endfunction



function void build_phase(uvm_phase phase);
super.build_phase(phase);
endfunction



task run_phase(uvm_phase phase);
seq = sequence1::type_id::create("seq",this);

phase.raise_objection(this);

seq.start(env.agent1.seqr);

phase.drop_objection(this);


endtask


endclass

//*******************************************************


endpackage
