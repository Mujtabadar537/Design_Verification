`include "uvm_macros.svh"

package uvmpackage;

import uvm_pkg::*;


//-----------------------sequence_item class------------------------------

class sequence_item extends uvm_sequence_item;

rand bit reset;
rand bit d;

bit q,qbar;

`uvm_object_utils_begin(sequence_item)

`uvm_field_int(reset,UVM_DEFAULT+UVM_DEC)
`uvm_field_int(d,UVM_DEFAULT+UVM_DEC)
`uvm_field_int(q,UVM_DEFAULT+UVM_DEC)


`uvm_object_utils_end


function new(string name = "sequence_item");
super.new(name);
endfunction


endclass : sequence_item


//---------------------------Sequence1 class------------------------------

//This sequence is for reset = 0
/**class sequence1 extends uvm_sequence #(sequence_item);

`uvm_object_utils(sequence1)

function new(string name = "sequence1");
super.new(name);
endfunction

task body;

req = sequence_item::type_id::create("req");//creating an instance of transaction or sequence item using factory method

repeat(5) begin

start_item(req);
assert(req.randomize());
if(!req.randomize()) begin
`uvm_error("SEQUENCE1 CLASS","RANDOMIZATION OF DATA HAS FAILED!!!!")
end

else begin
req.reset = 1;
`uvm_info("SEQUENCE1 CLASS","DATA HAS BEEN RANDOMIZED AND SEND TO DRIVER",UVM_NONE);
req.print();
end


finish_item(req);

end

endtask

endclass : sequence1**/



//---------------------------Sequence2 class------------------------------

//This sequence is for reset = 1
class sequence2 extends uvm_sequence #(sequence_item);

`uvm_object_utils(sequence2)

function new(string name = "sequence2");
super.new(name);
endfunction

task body;

req = sequence_item::type_id::create("req");//creating an instance of transaction or sequence item using factory method

repeat(5) begin

start_item(req);
assert(req.randomize());
if(!req.randomize()) begin
`uvm_error("SEQUENCE2 CLASS","RANDOMIZATION OF DATA HAS FAILED!!!!")
end

else begin
req.reset = 0;
`uvm_info("SEQUENCE2 CLASS","DATA HAS BEEN RANDOMIZED AND SEND TO DRIVER",UVM_NONE);
req.print();
end


finish_item(req);

end

endtask

endclass : sequence2


//---------------------------Sequence3 class------------------------------

//This sequence is for random values of d and reset
/**class sequence3 extends uvm_sequence #(sequence_item);

`uvm_object_utils(sequence3)

function new(string name = "sequence3");
super.new(name);
endfunction

task body;

req = sequence_item::type_id::create("req");//creating an instance of transaction or sequence item using factory method

repeat(5) begin

start_item(req);
assert(req.randomize());
if(!req.randomize()) begin
`uvm_error("SEQUENCE3 CLASS","RANDOMIZATION OF DATA HAS FAILED!!!!")
end

else begin
`uvm_info("SEQUENCE3 CLASS","DATA HAS BEEN RANDOMIZED AND SEND TO DRIVER",UVM_NONE);
req.print();
end


finish_item(req);

end

endtask

endclass : sequence3**/


//---------------------------Sequencer class------------------------------

class sequencer extends uvm_sequencer #(sequence_item);

`uvm_component_utils(sequencer)

function new(string name = "sequencer",uvm_component parent);
super.new(name,parent);
endfunction

endclass : sequencer



//---------------------------Driver class----------------------------------

class driver extends uvm_driver #(sequence_item);

`uvm_component_utils(driver)

virtual dut_if vif;


function new(string name = "driver",uvm_component parent);
super.new(name,parent);
endfunction

function void build_phase(uvm_phase phase);
super.build_phase(phase);

req = sequence_item::type_id::create("req");

if(!uvm_config_db #(virtual dut_if)::get(this,"","virtual_interface",vif)) begin
`uvm_fatal("DRIVER CLASS","UNABLE TO GET VIRTUAL INTERFACE")
end

endfunction


task run_phase(uvm_phase phase);

forever begin

seq_item_port.get_next_item(req);

//driving the inputs to the DUT with the help of virtual interface
vif.reset <= req.reset;
vif.d <= req.d;

//logic for detecting any error during the driving of signals
if(!(vif.reset <= req.reset)) begin
	if(!(vif.d <= req.d)) begin
	`uvm_error("DRIVER CLASS","FAILED TO SEND DATA TO DUT!!!")
	end

end

else begin
`uvm_info("DRIVER CLASS","DATA HAS BEEN SEND TO DUT SUCCESSFULLY",UVM_NONE)
req.print();
repeat(5) @(posedge vif.clk);
end

seq_item_port.item_done();

end

endtask

endclass : driver


//---------------------------Monitor class----------------------------------

class monitor extends uvm_monitor;

sequence_item transaction;
virtual dut_if vif;
uvm_analysis_port #(sequence_item) analysis_port;

`uvm_component_utils(monitor)

function new(string name = "monitor",uvm_component parent);
super.new(name,parent);
analysis_port = new("analysis_port",this);
endfunction


function void build_phase(uvm_phase phase);
super.build_phase(phase);
transaction = sequence_item::type_id::create("transaction",this);

if(!uvm_config_db #(virtual dut_if)::get(this,"","virtual_interface",vif)) begin
`uvm_fatal("DRIVER CLASS","UNABLE TO GET VIRTUAL INTERFACE")
end

endfunction


task run_phase(uvm_phase phase);

forever begin

//sending data from DUT to monitor through interface
repeat(5) @(posedge vif.clk);

transaction.reset <= vif.reset;
transaction.d <= vif.d;
transaction.q <= vif.q;

transaction.print();

analysis_port.write(transaction);



end

endtask


endclass : monitor



//---------------------------Agent class----------------------------------

class agent extends uvm_agent;

`uvm_component_utils(agent)


driver driver_h;
monitor monitor_h;
sequencer sequencer_h;


virtual dut_if vif;


function new(string name = "agent" , uvm_component parent);
super.new(name,parent);
endfunction


function void build_phase(uvm_phase phase);
super.build_phase(phase);

monitor_h = monitor::type_id::create("monitor_h",this);

if(!uvm_config_db #(virtual dut_if)::get(this,"","virtual_interface",vif)) begin
`uvm_fatal("AGENT CLASS","UNABLE TO GET VIRTUAL INTERFACE")
end


driver_h = driver::type_id::create("driver_h",this);
sequencer_h = sequencer::type_id::create("sequencer_h",this);




endfunction



function void connect_phase(uvm_phase phase);
super.connect_phase(phase);

//if(a_config.is_active == UVM_ACTIVE) begin
driver_h.seq_item_port.connect(sequencer_h.seq_item_export);
//end

endfunction

endclass : agent


//---------------------------Scoreboard class----------------------------------


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


function void write(input sequence_item transaction);

`uvm_info("SCOREBOARD CLASS","DATA HAS BEEN RECIEVED BY SCOREBOARD",UVM_MEDIUM)
transaction.print();

if(transaction.reset) begin
`uvm_info("SCOREBOARD CLASS","D FLIPFLOP HAS BEEN RESET",UVM_NONE)
end

else if(!transaction.reset && (transaction.q == transaction.d)) begin
`uvm_info("SCOREBOARD CLASS","TEST PASSED",UVM_NONE)
end

else
`uvm_info("SCOREBOARD CLASS","TEST FAILED",UVM_NONE)
     
endfunction

endclass


//---------------------------Environment class----------------------------------

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


//--------------------------Test class--------------------

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
`uvm_info("REPORT PHASE","-----------TEST PASSED----------",UVM_NONE);
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
`uvm_info("REPORT PHASE","-----------TEST FAILED----------",UVM_NONE);
`uvm_info("REPORT PHASE","--------------------------------",UVM_NONE);

end


endfunction




endclass



class test1 extends base_test;

`uvm_component_utils(test1)

//sequence1 seq1;
sequence2 seq2;
//sequence3 seq3;

function new(string name = "test1" , uvm_component parent);
super.new(name,parent);
endfunction



function void build_phase(uvm_phase phase);
super.build_phase(phase);
endfunction



task run_phase(uvm_phase phase);

//seq1 = sequence1::type_id::create("seq1");
seq2 = sequence2::type_id::create("seq2");
//seq3 = sequence3::type_id::create("seq3");

phase.raise_objection(this);

//seq1.start(env_h.agent_h.sequencer_h);
//#60;
seq2.start(env_h.agent_h.sequencer_h);
//#60;
//seq3.start(env_h.agent_h.sequencer_h);

phase.drop_objection(this);


endtask


endclass





endpackage
