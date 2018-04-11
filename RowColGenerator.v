`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    18:41:53 04/10/2018 
// Design Name: 
// Module Name:    RowColGenerator 
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
module RowColGenerator(
	 input clk,
    input h_sync,
    input v_sync,
    output [3:0] row,
    output [3:0] col
    );
	
	reg [9:0] xcount;
	reg [9:0] ycount;
	
	assign row = x/100;
	assign col = y/60;
	
	always @ (posedge clk)
	  begin
	    if(h_sync == 0)
		   begin
			  x<=0;
			  y<=y+1;
			end
		 else
		   begin
			  x<=x+1;
			end
		 if(y_sync == 0)
		   begin
			  y<=0;
			end
	  end

endmodule
