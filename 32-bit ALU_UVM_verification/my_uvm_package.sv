`include "uvm_macros.svh"

package my_uvm_package;

import uvm_pkg::*;

//------------ Sequence item class -------------

class sequence_item extends uvm_sequence_item;

rand bit [31:0]in1;
rand bit [31:0]in2;
rand bit [2:0]ALUControl;

bit [31:0]ALUResult;
bit zero;

constraint ALUControl_constraint {ALUControl >= 3'b000;
				  ALUControl <= 3'b110;}

constraint in1_constraint {in1 >= 32'h0;
			   in1 <= 32'h15;}

constraint in2_constraint {in2 >= 32'h0;
			   in2 <= 32'h15;}



`uvm_object_utils_begin(sequence_item)

`uvm_field_int(in1,UVM_DEFAULT + UVM_DEC)
`uvm_field_int(in2,UVM_DEFAULT + UVM_DEC)
`uvm_field_int(ALUControl,UVM_DEFAULT + UVM_DEC)
`uvm_field_int(ALUResult,UVM_DEFAULT + UVM_DEC)
`uvm_field_int(zero,UVM_DEFAULT + UVM_DEC)

`uvm_object_utils_end


function new(string name = "sequence_item");
super.new(name);
endfunction

endclass


//------------ Sequence class ----------------

class sequence1 extends uvm_sequence #(sequence_item);

`uvm_object_utils(sequence1)

function new(string name = "sequence1");
super.new(name);
endfunction



task body;

req = sequence_item::type_id::create("req");

repeat(10) begin

start_item(req);
req.randomize();

if(!(req.randomize())) begin
	`uvm_info("SEQUENCE1 CLASS","Randomization of data has failed!",UVM_NONE)
end

else begin
`uvm_info("SEQUENCE1 CLASS","Randomization of data is successfull",UVM_NONE)
`uvm_info("SEQUENCE1 CLASS","Data has been send to driver",UVM_NONE)
finish_item(req);
end



end

endtask


endclass



//------------ Sequencer class ----------------

class sequencer extends uvm_sequencer #(sequence_item);

`uvm_component_utils(sequencer)

function new(string name = "sequencer" , uvm_component parent);
super.new(name , parent);
endfunction

endclass


//------------ Driver class ----------------

class driver extends uvm_driver #(sequence_item);

`uvm_component_utils(driver)

virtual alu_if vif;

function new(string name = "driver" , uvm_component parent);
super.new(name,parent);
endfunction


function void build_phase(uvm_phase phase);
super.build_phase(phase);
req = sequence_item::type_id::create("req");

if(!uvm_config_db #(virtual alu_if)::get(this,"","virtual_interface",vif))
	`uvm_fatal("DRIVER CLASS","Unable to get virtual interface")

endfunction



virtual task run_phase(uvm_phase phase);

forever begin

seq_item_port.get_next_item(req);


vif.in1 <= req.in1;
vif.in2 <= req.in2;
vif.ALUControl <= req.ALUControl;
vif.ALUResult <= req.ALUResult;
vif.zero <= req.zero;


`uvm_info("DRIVER CLASS","Data has been recieved by driver",UVM_NONE)
#10;

seq_item_port.item_done();


end



endtask


endclass


//------------ Monitor class ----------------

class monitor extends uvm_monitor;

`uvm_component_utils(monitor)

sequence_item tx;

virtual alu_if vif;

uvm_analysis_port #(sequence_item) analysis_port;


function new(string name = "monitor" , uvm_component parent);
super.new(name,parent);
analysis_port = new("analysis_port",this);
endfunction


function void build_phase(uvm_phase phase);
super.build_phase(phase);


tx = sequence_item::type_id::create("tx");

if(!uvm_config_db #(virtual alu_if)::get(this,"","virtual_interface",vif))
	`uvm_fatal("MONITOR CLASS","Unable to get virtual interface")

endfunction


virtual task run_phase(uvm_phase phase);

forever begin

#10;
tx.in1 <= vif.in1;
tx.in2 <= vif.in2;
tx.ALUControl <= vif.ALUControl;
tx.ALUResult <= vif.ALUResult;
tx.zero <= vif.zero;

`uvm_info("MONITOR CLASS","Data has been send to scoreboard",UVM_NONE)

analysis_port.write(tx);


end



endtask



endclass





//------------ Agent class ----------------

class agent extends uvm_agent;

`uvm_component_utils(agent)

driver driver_h;
monitor monitor_h;
sequencer sequencer_h;

virtual alu_if vif;


function new(string name = "agent" , uvm_component parent);
super.new(name,parent);
endfunction


function void build_phase(uvm_phase phase);
super.build_phase(phase);

monitor_h = monitor::type_id::create("monitor_h",this);
driver_h = driver::type_id::create("driver_h",this);
sequencer_h = sequencer::type_id::create("sequencer_h",this);

if(!uvm_config_db #(virtual alu_if)::get(this,"","virtual_interface",vif)) begin
	`uvm_fatal("AGENT CLASS","Unable to get virtual interface")
end



endfunction



function void connect_phase(uvm_phase phase);
super.connect_phase(phase);


driver_h.seq_item_port.connect(sequencer_h.seq_item_export);

endfunction

endclass


//------------ Scoreboard class ----------------


function void check1(input sequence_item trans);
if(trans.ALUControl == 3'b000) begin
	if(trans.ALUResult == (trans.in1 + trans.in2)) begin
		`uvm_info("SCOREBOARD CLASS","Test passed for addition",UVM_NONE);
	end
end
endfunction


function void check2(input sequence_item trans);
if(trans.ALUControl == 3'b001) begin
	if(trans.ALUResult == (trans.in1 - trans.in2)) begin
		`uvm_info("SCOREBOARD CLASS","Test passed for subtraction",UVM_NONE);
	end
end
endfunction


function void check3(input sequence_item trans);
if(trans.ALUControl == 3'b010) begin
	if(trans.ALUResult == (trans.in1 & trans.in2)) begin
		`uvm_info("SCOREBOARD CLASS","Test passed for & operation",UVM_NONE);
	end
end
endfunction


function void check4(input sequence_item trans);
if(trans.ALUControl == 3'b011) begin
	if(trans.ALUResult == (trans.in1 | trans.in2)) begin
		`uvm_info("SCOREBOARD CLASS","Test passed for | operation",UVM_NONE);
	end
end
endfunction


function void check5(input sequence_item trans);
if(trans.ALUControl == 3'b100) begin
	if(trans.ALUResult == (trans.in1 ^ trans.in2)) begin
		`uvm_info("SCOREBOARD CLASS","Test passed for ^ operation",UVM_NONE);
	end
end

endfunction


function void check6(input sequence_item trans);
if(trans.ALUControl == 3'b101) begin
	if(trans.ALUResult == (trans.in1 * trans.in2)) begin
		`uvm_info("SCOREBOARD CLASS","Test passed for multiplication operation",UVM_NONE);
	end
end

endfunction


function void check7(input sequence_item trans);
if(trans.ALUControl == 3'b110) begin
	if(trans.ALUResult == (trans.in1 / trans.in2)) begin
		`uvm_info("SCOREBOARD CLASS","Test passed for division operation",UVM_NONE);
	end
end
endfunction




class scoreboard extends uvm_scoreboard;

`uvm_component_utils(scoreboard)

uvm_analysis_imp #(sequence_item , scoreboard) analysis_imp;

sequence_item tx;

function new(string name = "scoreboard" , uvm_component parent);
super.new(name,parent);
analysis_imp = new("analysis_imp" , this);
endfunction



function void build_phase(uvm_phase phase);
super.build_phase(phase);


tx = sequence_item::type_id::create("tx");


endfunction


function void write(input sequence_item trans);

`uvm_info("SCOREBOARD CLASS","Data has been recieved by scoreboard",UVM_NONE)

`uvm_info("SCOREBOARD CLASS",$sformatf("in1 =  0x%0h",trans.in1),UVM_NONE) 
`uvm_info("SCOREBOARD CLASS",$sformatf("in2 =  0x%0h",trans.in2),UVM_NONE) 
`uvm_info("SCOREBOARD CLASS",$sformatf("ALUControl =  0x%0h",trans.ALUControl),UVM_NONE) 
`uvm_info("SCOREBOARD CLASS",$sformatf("ALUResult =  0x%0h",trans.ALUResult),UVM_NONE) 
`uvm_info("SCOREBOARD CLASS",$sformatf("zero =  0x%0h",trans.zero),UVM_NONE) 

check1(trans);
check2(trans);
check3(trans);
check4(trans);
check5(trans);
check6(trans);
check7(trans);
	
endfunction

endclass



//------------ Environment class ----------------

class environment extends uvm_env;

`uvm_component_utils(environment)

agent agent_h;
scoreboard scoreboard_h;


function new(string name = "environment" , uvm_component parent);
super.new(name,parent);
endfunction



function void build_phase(uvm_phase phase);
super.build_phase(phase);
agent_h = agent::type_id::create("agent_h",this);
scoreboard_h = scoreboard::type_id::create("scoreboard_h",this);
endfunction


function void connect_phase(uvm_phase phase);
super.connect_phase(phase);
agent_h.monitor_h.analysis_port.connect(scoreboard_h.analysis_imp);
endfunction



endclass



//------------ Test class ----------------

class base_test extends uvm_test;

`uvm_component_utils(base_test)

environment env_h;
//agent_config a_config;


function new(string name = "base_test" , uvm_component parent);
super.new(name,parent);
endfunction



function void build_phase(uvm_phase phase);
super.build_phase(phase);

env_h = environment::type_id::create("env_h",this);
//a_config = agent_config::type_id::create("a_config",this);
//uvm_config_db #(agent_config)::set(this,"*","agent_config",a_config);

endfunction



function void end_of_elaboration_phase(uvm_phase phase);
super.end_of_elaboration_phase(phase);
uvm_top.print_topology();
endfunction



function void report_phase(uvm_phase phase);

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


endfunction




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

seq.start(env_h.agent_h.sequencer_h);

phase.drop_objection(this);


endtask


endclass



endpackage
