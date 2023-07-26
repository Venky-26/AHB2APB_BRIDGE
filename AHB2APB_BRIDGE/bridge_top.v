module bridge_top(hclk,hresetn,hwrite,haddr,hwdata,hreadyin,htrans,prdata,pwrite,penable,psel,paddr,pwdata,hrdata,hr_readyout,hresp);


////////input ports//////////
input hclk,hresetn,hwrite,hreadyin;
input [1:0]htrans;
input [31:0]haddr,hwdata,prdata;

///////output ports/////////
output pwrite,penable,hr_readyout;
output [1:0]hresp;
output [2:0]psel;
output [31:0]paddr,pwdata,hrdata;

////intermediate wires////
wire [31:0] hwdata1,hwdata2,hwdata3,hwdata4,haddr1,haddr2,haddr3,haddr4,prdata;
wire [2:0]tempselx;
wire valid,hwritereg,hwritereg1;


//////ahb_slave instantiation
ahb_slave ahb_sl(hclk,hresetn,hwrite,hreadyin,htrans,haddr,hwdata,valid,haddr1,haddr2,haddr3,haddr4,hwdata1,hwdata2,hwdata3,hwdata4,hwritereg,hwritereg1,tempselx);
//////apb_controller instantiation
apb_controller apb_c(hclk,hresetn,hwrite,hwritereg,hwritereg1,haddr1,haddr2,haddr3,haddr4,haddr,hwdata,hwdata1,hwdata2,hwdata3,hwdata4,tempselx,valid,prdata,pwrite,penable,psel,paddr,pwdata,hr_readyout,hresp,hrdata);
endmodule

