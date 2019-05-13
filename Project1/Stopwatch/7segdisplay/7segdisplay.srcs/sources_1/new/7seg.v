`timescale 1ns / 1ps
module seg7decimal(
    input [15:0] x,
    input clk,
    input clr,
    input start,
    input reset,
    input laps,
    output reg [6:0] a_to_g,
    output reg [3:0] an,
    output wire dp 
	 );
	 
	 
wire [1:0] s;	 
reg [3:0] digit;
wire [3:0] aen;
reg [19:0] clkdiv;
reg start_n;
reg start_ff = 0;
assign dp = 1;
assign s = clkdiv[19:18];
assign aen = 4'b1111; // all turned off initially

// quad 4to1 MUX.

reg [15:0] reg_d = 0;
reg [15:0] reg_laps_1;
reg[15:0] reg_laps_2;
reg[15:0] reg_laps_3;
reg[15:0] reg_laps_4;

reg [3:0] temp_d0 = 4'b0000, temp_d1 = 4'b0000, temp_d2 = 4'b0000, temp_d3 = 4'b0000;
reg [26:0] one_sec_counter = 1;
reg [22:0] yet_another_counter = 0;
always @(posedge clk)
begin
    one_sec_counter = one_sec_counter + 1;
    if(one_sec_counter >= 27'b101111111111111111111111111)
        one_sec_counter = 0;
    yet_another_counter = yet_another_counter + 1;
end

always @(posedge clk)
begin
    start_ff = x[15];
end

always @(posedge clk)
begin
if(start_ff == 1)
begin
    if(one_sec_counter == 0)
    begin
        temp_d0 = temp_d0 + 1;
        if(temp_d0 == 10)
        begin
            temp_d0 = 0;
            temp_d1 = temp_d1 + 1;
        
            if(temp_d1 == 6)
            begin
            temp_d1 = 0;
            temp_d2 = temp_d2 + 1;
                if(temp_d2 == 10)
                begin
                    temp_d3 = temp_d3 + 1;
                    temp_d2 = 0;
                    if(temp_d3 == 6)
                    begin
                        temp_d3 = 0;
                    end
                end 
            end
        end
    end
 end
    
 else if(start_ff == 0 && reset == 1) 
 begin
    temp_d0 <= 0;
    temp_d1 <= 0;
    temp_d2 <= 0;
    temp_d3 <= 0;
//    reg_laps_1 = 0;
//    reg_laps_2 = 0;
//    reg_laps_3 = 0;
//    reg_laps_4 = 0;
 end

end



always @(posedge clk)
begin
   
   if(x[0] == 0 && x[1] == 0 && x[2] == 0 && x[3] == 0)
   begin
    reg_d[3:0] = temp_d0;
    reg_d[7:4] = temp_d1;
    reg_d[11:8] = temp_d2;
    reg_d[15:12] = temp_d3;
   end
   
   else if(x[0] == 1 && x[1] == 0 && x[2] == 0 && x[3] == 0)
        reg_d = reg_laps_1;
   
   else if(x[0] == 0 && x[1] == 1 && x[2] == 0 && x[3] == 0)
        reg_d = reg_laps_2;
        
   else if(x[0] == 0 && x[1] == 0 && x[2] == 1 && x[3] == 0)
         reg_d = reg_laps_3;
             
   else if(x[0] == 0 && x[1] == 0 && x[2] == 0 && x[3] == 1)
         reg_d = reg_laps_4;
         
   
   
    if(laps == 1 && yet_another_counter == 0)
    begin
        reg_laps_4 = reg_laps_3;
        reg_laps_3 = reg_laps_2;
        reg_laps_2 = reg_laps_1;
        reg_laps_1 = reg_d;
    end
    
end


always @(posedge clk)// or posedge clr)
	
	case(s)
	0:digit = reg_d[3:0]; // s is 00 -->0 ;  digit gets assigned 4 bit value assigned to x[3:0]
	1:digit = reg_d[7:4]; // s is 01 -->1 ;  digit gets assigned 4 bit value assigned to x[7:4]
	2:digit = reg_d[11:8]; // s is 10 -->2 ;  digit gets assigned 4 bit value assigned to x[11:8
	3:digit = reg_d[15:12]; // s is 11 -->3 ;  digit gets assigned 4 bit value assigned to x[15:12]
	
	default:digit = reg_d[3:0];
	
	endcase
	
	//decoder or truth-table for 7a_to_g display values


always @(*)

case(digit)


//////////<---MSB-LSB<---
//////////////gfedcba////////////////////////////////////////////              a
0:a_to_g = 7'b1000000;////0000												   __					
1:a_to_g = 7'b1111001;////0001												f/	  /b
2:a_to_g = 7'b0100100;////0010												  g
//                                                                           __	
3:a_to_g = 7'b0110000;////0011										 	 e /   /c
4:a_to_g = 7'b0011001;////0100												 __
5:a_to_g = 7'b0010010;////0101                                               d  
6:a_to_g = 7'b0000010;////0110
7:a_to_g = 7'b1111000;////0111
8:a_to_g = 7'b0000000;////1000
9:a_to_g = 7'b0010000;////1001
'hA:a_to_g = 7'b0111111; // dash-(g)
'hB:a_to_g = 7'b1111111; // all turned off
'hC:a_to_g = 7'b1110111;

default: a_to_g = 7'b0000000; // U

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
