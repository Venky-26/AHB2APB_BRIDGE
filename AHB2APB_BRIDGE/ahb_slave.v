//RESPONSIBILITIES OF AHB_SLAVE MODULE
//ahb_slave have three responsibilities 
//i)   The valid transfer detection which is used to determine whena a valid transfer is accessing the slave
//ii)  The address and control registers, which are used to store the information from the address phase of the transfer for use in the dataphase
//iii) Address decoding to generate tempselx signal to select any peripherals.

module ahb_slave(hclk,hresetn,hwrite,hreadyin,htrans,haddr,hwdata,valid,haddr1,haddr2,haddr3,haddr4,hwdata1,hwdata2,hwdata3,hwdata4,hwritereg,hwritereg1,tempselx);


////////input ports//////////
input hclk,hresetn,hwrite,hreadyin;
input [1:0]htrans;
input [31:0]haddr,hwdata;///


///////output ports/////////
output reg valid,hwritereg,hwritereg1;
output reg [2:0]tempselx;
output reg [31:0] haddr1,haddr2,haddr3,haddr4,hwdata1,hwdata2,hwdata3,hwdata4;



//storing addresses in registers
always @(posedge hclk)
  begin
    if(!hresetn)
      begin
        haddr1<=0;
        haddr2<=0;
	haddr3<=0;
        haddr4<=0;
      end
    else
      begin
        haddr1<=haddr;
        haddr2<=haddr1;
	haddr3<=haddr2;
	 haddr4<=haddr3;
      end
  end
  
//storing data in registers
always @(posedge hclk)
  begin
    if(!hresetn)
      begin
        hwdata1<=0;
        hwdata2<=0;
	hwdata3<=0;
        hwdata4<=0;
      end
    else
      begin
        hwdata1<=hwdata;
        hwdata2<=hwdata1;
	hwdata3<=hwdata2;
        hwdata4<=hwdata3;
      end
  end

  //storing constrol signals in registers
always @(posedge hclk)
  begin
    if(!hresetn)
      begin
        hwritereg<=0;
        hwritereg1<=0; 
      end
    else
      begin
        hwritereg<=hwrite;
        hwritereg1<=hwritereg;
      end
  end


////////generating valid signal////////
///3 conditions for valid signal 
///i)hreadyin=1(indicates master ready to transfer)
//ii)address range between 8000_0000 and 8c00_0000
//iii)htrans should be either 10(non-seq transfer) or 11(seq transfer)
always @(*)
  begin
    valid=1'b0;
    if(hreadyin==1 && haddr>=32'h8000_0000 && haddr<32'h8c00_0000 && (htrans==2'b10 || htrans==2'b11))
      valid=1;
    else
      valid=0;
  end

////////generating tempselx signal///////
//3 peripherals are defined between 8000_0000 and 8c00_0000 coded with 3 bit hot encoding
always @(*)
  begin
    tempselx=3'b000;
    if(haddr>=32'h8000_0000 && haddr<32'h8400_0000)
      tempselx=3'b001;//peripheral 1(interrupt controller)
    else if(haddr>=32'h8400_0000 && haddr<32'h8800_0000)
      tempselx=3'b010;//peripheral 2(Counter timers)
    else if(haddr>=32'h8800_0000 && haddr<32'h8c00_0000)
      tempselx=3'b100;//peripheral 3(Remap and pause)
  end 
endmodule
