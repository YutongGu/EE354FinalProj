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
    input [9:0] xcount,
    input [9:0] ycount,
	 input indisplay,
    output [3:0] row,
    output [3:0] col
    );
	
	always@(posedge clk)
	  begin
	    if(indisplay)
		   begin
			  row <= xcount/80;
			  col <= ycount/60;
		   end 
	  end

endmodule
