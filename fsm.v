`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    18:37:44 04/10/2018 
// Design Name: 
// Module Name:    fsm 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module fsm(
	 input clk,
    input btn,
    input updateClk,
	 input reset,
    output reg [7:0] val,
    output reg [2:0] rowIndex,
    output reg writeStrobe,
	 output reg clrarray,
	 output reg [2:0] state
    );

localparam
 INIT   = 3'b000,
 TRACE  = 3'b001,
 CHECK   = 3'b010,
 UPDATE  = 3'b100,
 BLINK  = 3'b110,
 WIN  = 3'b101,
 LOSE  = 3'b111,
 UNKN  = 3'bxxx,
 RIGHT = 1'b1,
 LEFT = 1'b0;
 

 reg [7:0] currRow;
 reg [7:0] prevRow;
 reg [7:0] nextRow;
 
 reg dir;
 wire ack;
 wire [2:0] rowMax;
reg [3:0] count;

assign rowMax = 3'b111;
assign ack = ((state == WIN | state == LOSE) & btn);


//start of state machine
always @(posedge clk) //asynchronous active_high Reset //YG: isn't there a thing against asynchronous resets?
	begin  
	   if (reset) 
	       begin
	           state <= INIT;
	       end
       else // under positive edge of the clock
         begin
            case (state) // state and data transfers
                 INIT:
						  begin
							// state transitions
								state <= TRACE;
								clrarray <= 1;
							// RTL
								currRow <= 8'b11100000;
								prevRow <= 8'b11111111;
								nextRow <= 8'b00000000;
								rowIndex <= 0;
								count <= 0;
								dir <= RIGHT;
								writeStrobe <= 1;
						  end
                       
                 TRACE:               
							begin  
							// state transition
								clrarray <= 0;
								if(btn)
									begin
										state <= CHECK;
										nextRow <= (currRow & prevRow);
										//currRow <= (currRow & prevRow);
										val <= (currRow & prevRow);
										writeStrobe <= 1;
									end
								else
									writeStrobe <= 0;
							
							//RTL
								if(updateClk && ~btn)
									begin
										if(dir == LEFT)
											begin
												currRow <= currRow >> 1;
												val <= currRow >> 1;
											end
										else
											begin
												currRow <= currRow << 1;
												val <= currRow << 1;
											end
										writeStrobe <= 1;
									end
								//else
									
								if(currRow[0] == 1)
									dir <= RIGHT;
								else if(currRow[7] == 1)
									dir <= LEFT;
									
								
							end
						CHECK:   
						  begin 
								writeStrobe <= 0;
							// state transitions
								
								if(rowIndex < rowMax)
								begin
									if(currRow != prevRow & prevRow != 8'b11111111)
										state <= BLINK;
									else
										begin
											state <= UPDATE;
											rowIndex <= rowIndex + 1;
										end
								end
								else
									state <= WIN;
							//RTL
								
                    end
					  BLINK:
						begin
						//state transition
							
							writeStrobe <= 1;
							if(count == 5)
								begin
									if(nextRow == 0)
									begin
										writeStrobe <=0;
										state <= LOSE;
									end
									else
									begin
										state <= UPDATE;
										currRow <= (currRow & prevRow);
										count <= 0;
										writeStrobe <=0 ;
										rowIndex <= rowIndex + 1;
									end
								end
						
						//RTL
							if(updateClk)
								count <= count + 1;
							if(count[0])
								val <= currRow;
							else
								val <= (currRow & prevRow);
							
						end
                 UPDATE:       
						  begin 
						// state transitions
							if(rowIndex[0])
							begin
								if(nextRow[7] == 1)
									state <= TRACE;
							end
							else
							begin
								if(nextRow[0] == 1)
									state <= TRACE;
							end
							
						//RTL
							if(nextRow[7] != 1 & rowIndex[0])
								nextRow <= nextRow << 1;
							else if(nextRow[0] != 1 & ~rowIndex[0])
								nextRow <= nextRow >> 1;
							else
								begin
									prevRow <= currRow;
									currRow <= nextRow;	
									val <= nextRow;
									writeStrobe <= 1;
								end
                    end  
						  
						  /*if(nextRow[7] == 1)
								state <= TRACE;
							
						//RTL
							if(nextRow[7] != 1)
								nextRow <= nextRow << 1;
							else
								begin
									prevRow <= currRow;
									currRow <= nextRow;	
									val <= nextRow;
									writeStrobe <= 1;
								end
                    end  */
						  
                 WIN:       
						  begin 
						// state transitions
							if(ack)
								state <= INIT;
                    end
						  
                 LOSE:       
						  begin 
						// state transitions
							if(ack)
								state <= INIT;
                    end
					  default: 
                    begin
                         state <= UNKN;    
                    end
            endcase
         end   
 end // end of always procedural block 


endmodule
