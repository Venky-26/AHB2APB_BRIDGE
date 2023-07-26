//RESPONSIBILITIES OF APB CONTROLLER
//i) APB transfer state machine(control the application of APB transfers based on the AHB inputs)
//ii)APB output signal generation(genarates all APB output signals based on the status of state)
//iii)AHB output signal generation(generates hrdata,hready_out,hrsep)
//
//  ****AHB signals are assigned such a way that protocol matches with the wave form ****
//

module apb_controller(hclk,hresetn,hwrite,hwritereg,hwritereg1,haddr1,haddr2,haddr3,haddr4,haddr,hwdata,hwdata1,hwdata2,hwdata3,hwdata4,tempselx,valid,prdata,pwrite,penable,psel,paddr,pwdata,hr_readyout,hresp,hrdata);



////////input ports//////////
input hclk,hresetn,hwrite,hwritereg,hwritereg1,valid;
input[31:0]haddr1,haddr2,haddr3,haddr4,haddr,hwdata1,hwdata2,hwdata3,hwdata4,hwdata,prdata;
input [2:0]tempselx;


///////output ports/////////
output reg hr_readyout,pwrite,penable;
output [1:0]hresp;
output reg [2:0]psel;
output reg [31:0]paddr,pwdata;
output [31:0]hrdata;



////intermediate register////
reg penable_temp,pwrite_temp,hr_readyout_temp;
reg [2:0]psel_temp;
reg [31:0]paddr_temp,pwdata_temp;
reg [2:0]present,next;


////////8 states of FSM//////
parameter ST_IDLE=3'b000,
          ST_READ=3'b001,
          ST_RENABLE=3'b010,
          ST_WENABLE=3'b011,
          ST_WRITE=3'b100,
          ST_WWAIT=3'b101,
          ST_WRITEP=3'b110,
          ST_WENABLEP=3'b111;

//present state logic
always@(posedge hclk)
  begin
    if(!hresetn)
      present<=ST_IDLE;
    else
      present<=next;
  end

//next state logic

always@ (*)
  begin
    next=ST_IDLE;
    case(present)
      ST_IDLE:
       begin
        if(valid==1 && hwrite==1)
          next=ST_WWAIT;
        else if(valid==1 && hwrite==0)
          next=ST_READ;
        else 
          next=ST_IDLE;
       end
      
      ST_WWAIT:
       begin
        if(valid)
          next=ST_WRITEP;
        else
          next=ST_WRITE;
       end

      ST_WRITE:
       begin
        if(valid)
          next=ST_WENABLEP;
        else
          next=ST_WENABLE;
       end

      ST_WENABLE:
       begin
        if(valid==1 && hwrite==0)
          next=ST_READ;
        else if(valid==1 && hwrite==1)
          next=ST_WWAIT;
        else if(valid==0)
          next=ST_IDLE;
       end
        
      ST_READ:next= ST_RENABLE;
        
      ST_RENABLE:
       begin
        if(valid==1 && hwrite==0)
          next=ST_READ;
        else if(valid==1 && hwrite==1)
          next=ST_WWAIT;
        else if(valid==0)
          next=ST_IDLE;
       end

      ST_WENABLEP:
       begin
        if(hwritereg1==0)
          next=ST_READ;
        else if(valid==1 && hwritereg==1)
          next=ST_WRITEP;
        else if(valid==0 && hwritereg1==1)
          next=ST_WRITE;
       end
        
      ST_WRITEP: next=ST_WENABLEP;

      default: next=ST_IDLE;
    endcase  
  end

//temporary output logic
always@(*)
  begin
    case(present)
      ST_IDLE:
       begin
        if(valid==1 && hwrite==0)
         begin
           paddr_temp=haddr;
			  pwdata_temp=hwdata;//undefined
           pwrite_temp=hwrite;//undefined
           psel_temp=tempselx;
           penable_temp=0;
           hr_readyout_temp=0;
         end
      

        else if(valid==1 && hwrite==1)
         begin
			  paddr_temp=haddr1;
			  pwrite_temp=hwritereg;
			  pwdata_temp=hwdata;
           psel_temp=0;
           penable_temp=0;
           hr_readyout_temp=1;
         end

        else
         begin
			  paddr_temp=haddr1;//undefined
			  pwrite_temp=hwritereg;//undefined
			  pwdata_temp=hwdata1;//undefined
           psel_temp=0;
           penable_temp=0;
           hr_readyout_temp=1'b1;
         end

       end

      ST_READ:
       begin
		   if(!hwritereg)////single and burst read
			begin
			  paddr_temp=haddr1;
	        pwdata_temp=hwdata;//undefined
	        pwrite_temp=0;
   	     psel_temp=tempselx;
           penable_temp=1;
           hr_readyout_temp = 1'b1;
			end
		 
		   else///back2back read 
			begin
	        paddr_temp=haddr3;
	        pwdata_temp=hwdata3;
	        pwrite_temp=0;
   	     psel_temp=tempselx;
           penable_temp=1;
           hr_readyout_temp = 1'b1;
		   end
       end

      ST_RENABLE:
       begin
        if(valid==1 && hwrite==0)
         begin
           paddr_temp=haddr;
			  pwdata_temp=hwdata;//undefined
           pwrite_temp=hwrite;
           psel_temp=tempselx;
           penable_temp=0;
           hr_readyout_temp=0;
         end
        else if(valid==1 && hwrite==1)
         begin
			  paddr_temp=haddr4;
			  pwdata_temp=hwdata4;
			  pwrite_temp=0;
           psel_temp=0;
           penable_temp=0;
           hr_readyout_temp=1;
         end
        else
         begin
			  paddr_temp=haddr2;
			  pwdata_temp=hwdata;
			  pwrite_temp=1'b0;
           psel_temp=0;
           penable_temp=0;
           hr_readyout_temp=1;//undefined
         end     
       end 

      ST_WWAIT:
       begin
		  if(valid)
		    begin
			   paddr_temp=haddr1;
            pwdata_temp=hwdata;
            pwrite_temp=hwritereg;/////hwrite--->hwritereg///back2back
            psel_temp=tempselx;
            penable_temp=0;
            hr_readyout_temp=0; 
			 end
		  else
		    begin
			   paddr_temp=haddr1;
            pwdata_temp=hwdata;
            pwrite_temp=hwritereg;/////hwrite--->hwritereg//single write
            psel_temp=tempselx;
            penable_temp=0;
            hr_readyout_temp=1;//undefined
			 end
           
       end

      ST_WRITE:
       begin
		   if(hwritereg1)///single write
			begin
			  paddr_temp=haddr2;////haddr2 is required
		     pwdata_temp=hwdata1;
		     psel_temp=tempselx;
		     pwrite_temp=1;
           penable_temp=1;
           hr_readyout_temp=1;//undefined
			end
			
			else////burst write
			begin
			  paddr_temp=haddr3;////haddr3 is required
		     pwdata_temp=hwdata1;
		     psel_temp=tempselx;
		     pwrite_temp=1;
           penable_temp=1;
           hr_readyout_temp=1;//undefined
			end
		   
       end

      ST_WENABLE://////
       begin
        if(valid==1 && hwrite==0)///no such trns
         begin
			  paddr_temp=haddr;//undefined
			  pwdata_temp=hwdata;//undefined
			  pwrite_temp=hwritereg;
           psel_temp=0;
           penable_temp=0;
           hr_readyout_temp=1'bx;
         end

        else if(valid==1 && hwrite==1)///no such trns
         begin 
           paddr_temp=haddr1;
			  pwdata_temp=hwdata;//undefined
           pwrite_temp=hwritereg;
           psel_temp=tempselx;
           penable_temp=0;
           hr_readyout_temp=0;
         end

        else
         begin
			  paddr_temp=haddr3;
			  pwdata_temp=hwdata2;
			  pwrite_temp=1;
           psel_temp=0;
           penable_temp=0;
           hr_readyout_temp=1;//undefined
         end 
       end
        
      ST_WRITEP:
       begin
	    if(hwritereg==0)/////back2back transaction//////hwritereg1 seems incorrect ?????
        begin
	     paddr_temp=haddr2;///
	     pwdata_temp=hwdata1;
	     pwrite_temp=1;
	     psel_temp=tempselx;
        penable_temp=1;
        hr_readyout_temp=0;		  
        end
       else if(hwdata2!=8'hxx)///////first writep to wenablep 
        begin
		    paddr_temp=haddr3;///haddr3 is required
		    pwdata_temp=hwdata1;
		    pwrite_temp=1;
			 psel_temp=tempselx;
          penable_temp=1;
          hr_readyout_temp=1;           
        end///////
      else//// further writep to wenablep
       begin
		   paddr_temp=haddr2;
		   pwdata_temp=hwdata1;
		   pwrite_temp=1;
			psel_temp=tempselx;
         penable_temp=1;
         hr_readyout_temp=1; 
       end
      end

      ST_WENABLEP:
       begin
		   if(valid==0 && hwritereg1==1)
			begin
			 paddr_temp=haddr2;
          pwdata_temp=hwdata;
          pwrite_temp=hwritereg1;/////hwrite--->hwritereg1
          psel_temp=tempselx;
          penable_temp=0;
          hr_readyout_temp=1'b1;//undefined 
			end
			
			else if(valid==1 && hwritereg==1)
			begin
          paddr_temp=haddr2;
          pwdata_temp=hwdata;
          pwrite_temp=hwritereg1;/////hwrite--->hwritereg1
          psel_temp=tempselx;
          penable_temp=0;
          hr_readyout_temp=0; 
			end
			else //if(hwritereg1)
			begin
          paddr_temp=haddr2;
          pwdata_temp=hwdata2;
          pwrite_temp=hwritereg1;/////hwrite--->hwritereg1
          psel_temp=tempselx;
          penable_temp=0;
          hr_readyout_temp=0;			
			end 
       end
		 
		  
      
    endcase
  end

//output logic
always @(posedge hclk)
  begin
    if(!hresetn)
      begin
        paddr<=0;
        pwdata<=0;
        pwrite<=0;
        psel<=0;
        penable<=0;
        hr_readyout<=1;
      end
    else
      begin
        paddr<=paddr_temp;
        pwdata<=pwdata_temp;
        pwrite<=pwrite_temp;
        psel<=psel_temp;
        penable<=penable_temp;
        hr_readyout<=hr_readyout_temp;
      end
  end
  
  assign hrdata=prdata;/////assigning prdata to hrdata
  assign hresp=0;////hresp is always okay (0)
  

endmodule
