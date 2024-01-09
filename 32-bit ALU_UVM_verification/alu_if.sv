interface alu_if;

//inputs
bit [31:0]in1,in2;
bit [2:0]ALUControl;


//outputs
bit [31:0]ALUResult;
bit zero;

endinterface
