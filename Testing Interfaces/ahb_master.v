`timescale 1ns/1ns
module ahb_master(hclk,hresetn,hreadyout,hrdata,hresp,hwrite,hreadyin,haddr,hwdata,htrans);


////////input ports//////
input hclk,hresetn,hreadyout;
input[1:0]hresp;
input [31:0]hrdata;

/////output ports//////
output reg hwrite,hreadyin;
output reg [1:0]htrans;
output reg [31:0]haddr,hwdata;

reg [2:0]hburst;//single,4,8,16...transfers
reg [2:0]hsize;//size 8,16,32,64..bits

integer i;


///////single write transaction//////
task single_write();
  begin
    @(posedge hclk)
    #1;
    begin
      hwrite=1;
      htrans=2'd2;////NON-SEQ
      hsize=0;///8bits
      hburst=0;//single
      hreadyin=1;
      haddr=32'h8000_0001;
    end

    @(posedge hclk)
    #1;
    begin
      hwrite=1'bx;
      htrans=2'd0;///IDLE
      hwdata=8'h80;
    end
  end
endtask


//////single read transaction/////
task single_read();
  begin
    @(posedge hclk)
    #1;
    begin
      hwrite=0;
      htrans=2'd2;
      hsize=0;//8bits
      hburst=0;//single
      hreadyin=1;
      haddr=32'h8000_0001;
    end

    @(posedge hclk)
    #1;
    begin
      hwrite=1'bx;
      htrans=2'd0;
    end
  end
endtask



/////////burst write transaction////
 task burst_write();
    begin
      @(posedge hclk);
        #1;
       begin
        hreadyin = 1;
        hwrite = 1;
        haddr = 32'h8000_1000;
        htrans = 2'd2;//NON-SEQ
        hburst = 1;//4 tranfers
        hsize = 0;//8bits
       end

      @(posedge hclk);
        #1;       
        hwdata = ($random)%256;
        haddr = haddr + 1'b1;
        htrans =2'd3;
     
              for(i=0;i<2;i=i+1)
                begin
                  @(posedge hclk);
                  #1;
                  hwdata = ($random)%256;
                  haddr = haddr + 1'b1;
                  htrans = 2'd3;//SEQ
                  @(posedge hclk);
                end
              wait(hreadyout);
              @(posedge hclk);
              #1;
              hwdata = ($random)%256;
              hwrite=1'bx;
              htrans = 2'd0;//IDEAL
    end
  endtask


///////burst read transaction//////
task burst_read();
    begin
      @(posedge hclk);
        #1;
       begin
        hreadyin = 1;
        hwrite = 0;
        haddr = 32'h8000_1000;
        htrans = 2'd2;//NON-SEQ
        hburst = 1;//4 tranfers
        hsize = 0;//8bits
       end

     
              for(i=0;i<3;i=i+1)
                begin
                  @(posedge hclk);
                  #1;
                  haddr = haddr + 1'b1;
                  htrans = 2'd3;//SEQ
                  @(posedge hclk);
                end
              wait(hreadyout);
              @(posedge hclk);
              #1;
               hwrite=1'bx;
              htrans = 2'd0;//IDEAL
    end
  endtask

task back_2_back();//starts with write followed by read followed by write and followed by read
  begin
   @(posedge hclk)
    #1;
    begin
      hwrite=1;
      htrans=2'd2;
      hsize=0;
      hburst=0;
      hreadyin=1;
      haddr=32'h8000_0001;
    end

   @(posedge hclk)
    #1;
    begin
      hwrite=0;
      haddr=32'h8000_0002;
      hwdata=($random)%256;
    end   

   @(posedge hclk)
    #1;
    begin
      hwrite=1;
      haddr=32'h8000_0003;
    end 
   @(posedge hclk)

   @(posedge hclk)
   @(posedge hclk)

   @(posedge hclk)
    #1;
    begin
      hwrite=0;
      haddr=32'h8000_0004;
      hwdata=($random)%256; 
    end     

    wait(hreadyout);
    @(posedge hclk);
    #1;
    hwrite=1'bx;
    htrans = 2'd0;



  end
endtask

endmodule
