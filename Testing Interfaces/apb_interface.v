`timescale 1ns/1ns
module apb_interface(pwrite,penable,psel,paddr,pwdata,pwrite_out,penable_out,psel_out,paddr_out,pwdata_out,prdata);


////input ports////
input pwrite,penable;
input [2:0]psel;
input [31:0]paddr,pwdata;


////output ports///////
output pwrite_out,penable_out;
output [2:0]psel_out;
output [31:0]paddr_out,pwdata_out;
output reg [31:0]prdata;

assign pwrite_out=pwrite;
assign penable_out=penable;
assign psel_out=psel;
assign paddr_out=paddr;
assign pwdata_out=pwdata;

always@(*)
  begin
    if(!pwrite&&penable)
      begin
        prdata=($random)%256;
      end
    else
      begin
        prdata=32'hxxxx_xxxx;
      end
  end

endmodule
