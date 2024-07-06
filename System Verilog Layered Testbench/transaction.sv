`ifndef TRANSACTION_SV
`define TRANSACTION_SV


class transaction;

rand logic [15:0]in1;
rand logic [15:0]in2;
rand logic cin;

logic [15:0]sum;
logic carry;


function void display(string class_name);
    $display("-------------------------[%s]--------------------------" , class_name);
    $display("in1 = %h , in2 = %h , cin  = %h , sum = %h , carry = %h",in1,in2,cin,sum,carry);
    $display("-------------------------------------------------------"); 
    $display("\n");
endfunction


endclass


`endif