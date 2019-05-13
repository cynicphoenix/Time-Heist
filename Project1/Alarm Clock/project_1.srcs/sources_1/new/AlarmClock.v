`timescale 1ns / 1ps

module seg7decimal(

	 input [15:0] x,
    input clk,
    input clr,
    output reg [6:0] seg,
    output reg [3:0] an,
    output wire dp 
	 );
	 
	 
wire [1:0] s;	 
reg [3:0] digit;
wire [3:0] aen;
reg [19:0] clkdiv;

assign dp = 1;
assign s = clkdiv[19:18];
assign aen = 4'b1111; // all turned off initially

// quad 4to1 MUX.


always @(posedge clk)// or posedge clr)
	
	case(s)
	0:digit = x[3:0]; // s is 00 -->0 ;  digit gets assigned 4 bit value assigned to x[3:0]
	1:digit = x[7:4]; // s is 01 -->1 ;  digit gets assigned 4 bit value assigned to x[7:4]
	2:digit = x[11:8]; // s is 10 -->2 ;  digit gets assigned 4 bit value assigned to x[11:8
	3:digit = x[15:12]; // s is 11 -->3 ;  digit gets assigned 4 bit value assigned to x[15:12]
	
	default:digit = x[3:0];
	
	endcase
	
	//decoder or truth-table for 7seg display values
	always @(*)

case(digit)


//////////<---MSB-LSB<---
//////////////gfedcba////////////////////////////////////////////              a
0:seg = 7'b1000000;////0000												   __					
1:seg = 7'b1111001;////0001												f/	  /b
2:seg = 7'b0100100;////0010												  g
//                                                                           __	
3:seg = 7'b0110000;////0011										 	 e /   /c
4:seg = 7'b0011001;////0100												 __
5:seg = 7'b0010010;////0101                                               d  
6:seg = 7'b0000010;////0110
7:seg = 7'b1111000;////0111
8:seg = 7'b0000000;////1000
9:seg = 7'b0010000;////1001
'hA:seg = 7'b0111111; // dash-(g)
'hB:seg = 7'b1111111; // all turned off
'hC:seg = 7'b1110111;

default: seg = 7'b0000000; // U

endcase


always @(*)begin
an=4'b1111;
if(aen[s] == 1)
an[s] = 0;
end


//clkdiv

always @(posedge clk or posedge clr) begin
if ( clr == 1)
clkdiv <= 0;
else
clkdiv <= clkdiv+1;
end


endmodule






//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 26.11.2018 22:43:42
// Design Name: 
// Module Name: AlarmClock
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////
module aclock (
 input reset,  
 input clk1,input clr1,
 input snooze,  
 input wire [1:0] H_in1, 
 input wire [3:0] H_in0, 
 input wire [3:0] M_in1, 
 input  wire [3:0] M_in0, 
 input LD_time,  
 input   LD_alarm,  
 input   STOP_al,  
 input   AL_ON,  
 output reg Alarm=0,  
 output reg [1:0]  H_out1, 

 output reg [3:0]  H_out0, 

 output reg [3:0]  M_out1, 

 output reg [3:0]  M_out0,
 
 output [6:0] seg1,
 output [3:0] an1,
 output dp1   
 
  
 
 /*output [3:0]  S_out1, 
 output [3:0]  S_out0*/  
 );
 
 reg [1:0] h_out1=2'b00;
 reg [3:0] h_out0=4'b0000;
 reg [3:0] m_out1=4'b0000;
 reg [3:0] m_out0=4'b0000;
 reg [3:0] s_out1=4'b0000;
 reg [3:0] s_out0=4'b0000;
 wire[15:0] result_8;
 assign result_8[15:14]=2'b00;
 assign result_8[13:12]=H_out1;
 assign result_8[11:8]=H_out0;
 assign result_8[7:4]=M_out1;
 assign result_8[3:0]=M_out0;

 reg [26:0] counter=27'b000000000000000000000000000;
 
 reg  [3:0]  S_out1=4'b0000; 
 reg  [3:0]  S_out0=4'b0000; 
   
 always @(posedge clk1)begin

    if(reset==1)begin
      h_out1<=2'b00;
      h_out0<=4'b0000;
      m_out1<=4'b0000;
      m_out0<=4'b0000;
      s_out1<=4'b0000;
      s_out0<=4'b0000;
      
      H_out1<=H_in1;
      H_out0<=H_in0;
      M_out1<=M_in1;
      M_out0<=M_in0;
      S_out1<=4'b0000;
      S_out0<=4'b0000;
      
      Alarm<=0;  
       counter=27'b000000000000000000000000000;
      
     end
     
     else if(LD_time==1)begin
     
          H_out1<=H_in1;
          H_out0<=H_in0;
          M_out1<=M_in1;
          M_out0<=M_in0;
          S_out1<=4'b0000;
          S_out0<=4'b0000;
           counter=27'b000000000000000000000000000;
        
     end
     
     else if(LD_alarm==1)begin
     
           h_out1<=H_in1;
           h_out0<=H_in0;
           m_out1<=M_in1;
           m_out0<=M_in0;
           s_out1<=4'b0000;
           s_out0<=4'b0000;
     
     end
     
     
     if(Alarm==1&&STOP_al==1)begin        
         Alarm<=0;
         if(snooze==1)begin
           
           m_out0<=M_out0;
           m_out1<=M_out1;
           h_out0<=H_out0;
           h_out1<=H_out1;
           
           m_out0<=m_out0+1;
            if(m_out0==4'b1010)begin
                                      
              m_out0<=4'b0000;
              m_out1<=m_out1+1;
                                                                                     
            end 
            if(m_out1==4'b0110)begin
              m_out1<=4'b0000;
              h_out0<=h_out0+1;
            end
                               
                               
                                
            if(h_out0==4'b1010)begin
                                
                h_out0<=4'b0000;
                h_out1<=h_out1+1;
                                                                     
            end 
                               
            if(h_out1==2'b10)begin
               if(h_out0==4'b0100)begin
                    h_out1<=0;
                    h_out0<=0;
               end
                               
            end
                     
         end 
     end
      
      else if({H_out1,H_out0,M_out1,M_out0,S_out1,S_out0}=={h_out1,h_out0,m_out1,m_out0,s_out1,s_out0})
      begin 
      if(AL_ON) Alarm <= 1; 
      end
      
      
      if(counter==27'b101111111111111111111111111)begin
           S_out0<=S_out0+1;
           counter=27'b000000000000000000000000000;
                            
      end
      
      
        if(S_out0==4'b1010)begin
                       
                        S_out0<=4'b0000;
                        S_out1<=S_out1+1;                                          
         end 
         
         if(S_out1==4'b0110)begin
                 S_out1<=4'b0000;
                 M_out0<=M_out0+1;
         end
         
                    
                     if(M_out0==4'b1010)begin
                            
                             M_out0<=4'b0000;
                             M_out1<=M_out1+1;
                                                                           
                     end 
                     if(M_out1==4'b0110)begin
                              M_out1<=4'b0000;
                              H_out0<=H_out0+1;
                     end
                     
                     
                      
                     if(H_out0==4'b1010)begin
                      
                          H_out0<=4'b0000;
                          H_out1<=H_out1+1;
                          /*
                          if(H_out1==2'b10)begin
                             
                              H_out1<=2'b00;
                                  
                          end*/
                         
                     end 
                     
                     if(H_out1==2'b10)begin
                         if(H_out0==4'b0100)begin
                            H_out1<=0;
                            H_out0<=0;
                         end
                     
                     end
               
      
     
            
      counter=counter+1;
 end
 
  seg7decimal (.x(result_8), .clk(clk1), .clr(clr1), .seg(seg1), .an(an1), .dp(dp1));
 
      
endmodule
     
     
     
     
   
  
    
 
  
    

