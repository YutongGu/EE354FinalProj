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
    input [7:0] rowRead,
    input btn,
    input updateClk,
	 input reset,
    output reg [7:0] val,
    output reg [2:0] rowIndex,
    output writeStrobe,
    output level
    );

localparam
 INIT   = 3'b000,
 TRACE  = 3'b001,
 CHECK   = 3'b010,
 UPDATE  = 3'b100,
 WIN  = 3'b101,
 LOSE  = 3'b111,
 UNKN  = 3'bxxx,
 RIGHT = 1'b1,
 LEFT = 1'b0;
 
 reg [2:0] state;
 reg [7:0] currRow;
 reg [7:0] prevRow;
 reg [7:0] nextRow;
 
 reg dir;
 reg [7:0] nextrow;
 wire ack;
 wire [2:0] rowMax;

assign rowMax = 3'b111;
 assign ack = ((state == WIN | state == LOSE) & btn);

//start of state machine
always @(posedge updateClk, posedge reset) //asynchronous active_high Reset
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
                        if(btn)
									state <= TRACE;
									
					// RTL
					   currRow <= 8'b11100000;
						prevRow <= 8'b11111111;
						nextRow <= 8'b00000000;
						rowIndex <= 0;
						dir <= RIGHT;
						
						  end
                       
                 TRACE:               
                    begin  
					// state transition
						if(btn)
							state <= CHECK;

					//RTL
						if(updateClk)
							begin
								if(dir == RIGHT)
									currRow <= currRow >> 1;
								else
									currRow <= currRow << 1;
							end
						if(currRow[0] == 1)
							dir <= RIGHT;
						else if(currRow[7] == 1)
							dir <= LEFT;
						if(btn)
							nextrow <= (currRow & prevRow);
							end
                 CHECK:       
						  begin 
					// state transitions
						if(nextRow[0] == 0)
							state <= LOSE;
						else
							begin
								if(rowIndex < rowMax)
									state <= UPDATE;
								else
									state <= WIN;
							end
					//RTL
						rowIndex <= rowIndex + 1;
						val <= nextRow;
                    end
						  
                 UPDATE:       
						  begin 
					// state transitions
						if(nextRow[0] == 1)
							state <= TRACE;
						
					//RTL
						if(nextRow[0] != 1)
							nextRow <= nextRow << 1;
						else
							begin
								prevRow <= currRow;
								currRow <= nextRow;
							end
						
							
                    end  
						  
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