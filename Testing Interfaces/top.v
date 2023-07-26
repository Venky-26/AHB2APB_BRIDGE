`timescale 1ns/1ns
module top();

reg hclk,hresetn;


///intermediate wires///
wire hreadyout;
wire[1:0]hresp;
wire [31:0]hrdata;

wire hwrite,hreadyin;
wire [1:0]htrans;
wire [31:0]haddr,hwdata,prdata;

wire pwrite,penable;
wire [2:0]psel;
wire [31:0]paddr,pwdata;

wire pwrite_out,penable_out;
wire [2:0]psel_out;
wire [31:0]paddr_out,pwdata_out;


////instantation of ahb master////
ahb_master AHB(hclk,hresetn,hreadyout,hrdata,hresp,hwrite,hreadyin,haddr,hwdata,htrans);

////instatiation of brdige top///
bridge_top Bridge(hclk,hresetn,hwrite,haddr,hwdata,hreadyin,htrans,prdata,pwrite,penable,psel,paddr,pwdata,hrdata,hreadyout,hresp);

////instantiaton of apb interface
apb_interface APB(pwrite,penable,psel,paddr,pwdata,pwrite_out,penable_out,psel_out,paddr_out,pwdata_out,prdata);

initial
  begin
    hclk=1'b0;
    forever #100 hclk=~hclk;
  end

task reset;
  begin
    @(negedge hclk)
      hresetn=1'b0;
    @(negedge hclk)
      hresetn=1'b1;
  end

endtask

initial
  begin
    reset;
//    AHB.single_write();
//    AHB.single_read();
//    AHB.burst_write();
//    AHB.burst_read();
    AHB.back_2_back();
    #500 $stop;

  end

endmodule
