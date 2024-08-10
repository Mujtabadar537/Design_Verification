module sequence_detector(

input logic clk,
input logic reset,
input logic in,

output logic out


);


typedef enum logic [3:0]{S0 , S1 , S2 , S3}states_t;

states_t current_state , next_state;


//Synchronus logic
always_ff @(posedge clk) begin

if(reset) begin
   current_state <= S0;
end

else begin
   current_state <= next_state;
end

end




//Next State Logic
always_comb begin

case(current_state)

S0:
  begin
  if(in == 0) begin
    next_state = S0;
    //out = 0;
  end
  else begin
    next_state = S1;
    //out = 0;
  end
  end


S1:
  begin
  if(in == 0) begin
    next_state = S2;
    //out = 0;
  end
  else begin
    next_state = S1;
    //out = 0;
  end
  end


S2:
  begin
  if(in == 0) begin
    next_state = S2;
    //out = 0;
  end
  else begin
    next_state = S3;
    //out = 0;
  end
  end


S3:
  begin
  if(in == 0) begin
    next_state = S3;
    //out = 0;
  end
  else begin
    next_state = S0;
    //out = 1;
  end
  end



endcase


end




//Ouput Logic
always_ff @(posedge clk) begin

if(reset) out <= 0;

else begin

case(current_state)

S0:
  begin
  if(in == 0) begin
    out <= 0;
  end
  else begin
    out <= 0;
  end
  end


S1:
  begin
  if(in == 0) begin
    out <= 0;
  end
  else begin
    out <= 0;
  end
  end


S2:
  begin
  if(in == 0) begin
    out <= 0;
  end
  else begin
    out <= 0;
  end
  end


S3:
  begin
  if(in == 0) begin
    out <= 0;
  end
  else begin
    out <= 1;
  end
  end



endcase

end


end


endmodule
