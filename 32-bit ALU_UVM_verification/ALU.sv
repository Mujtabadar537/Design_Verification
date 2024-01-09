module ALU(
  input [31:0] in1, in2,
  input [2:0] ALUControl,
  output logic [31:0] ALUResult,
  output logic zero
);

always_comb begin

  zero = 0;
  case (ALUControl)
    3'b000: ALUResult = in1 + in2;
    3'b001: ALUResult = in1 - in2;
    3'b010: ALUResult = in1 & in2;
    3'b011: ALUResult = in1 | in2;
    3'b100: ALUResult = in1 ^ in2;
    3'b101: ALUResult = in1 * in2;
    3'b110: ALUResult = in1 / in2;
   
    default: ALUResult = 0; 
  endcase

  if (ALUResult == 0) begin
    zero = 1;
  end
end

endmodule
