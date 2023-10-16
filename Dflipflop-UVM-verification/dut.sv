module dut(

input logic clk,reset,d,

output logic q,qbar

);

always_ff @(posedge clk) begin

if(!reset) begin
q <= d;

end

else begin
q <= 0;

end


end



endmodule
