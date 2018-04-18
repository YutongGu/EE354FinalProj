`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// VGA verilog template
// Author:  Da Cheng
//////////////////////////////////////////////////////////////////////////////////
module vga_demo(ClkPort, vga_h_sync, vga_v_sync, vga_r, vga_g, vga_b, Sw0, Sw1, btnU, btnD,
	St_ce_bar, St_rp_bar, Mt_ce_bar, Mt_St_oe_bar, Mt_St_we_bar,
	An0, An1, An2, An3, Ca, Cb, Cc, Cd, Ce, Cf, Cg, Dp,
	LD0, LD1, LD2, LD3, LD4, LD5, LD6, LD7);
	input ClkPort, Sw0, btnU, btnD, Sw0, Sw1;
	output St_ce_bar, St_rp_bar, Mt_ce_bar, Mt_St_oe_bar, Mt_St_we_bar;
	output vga_h_sync, vga_v_sync, vga_r, vga_g, vga_b;
	output An0, An1, An2, An3, Ca, Cb, Cc, Cd, Ce, Cf, Cg, Dp;
	output LD0, LD1, LD2, LD3, LD4, LD5, LD6, LD7;
	wire vga_r0, vga_g0, vga_r1, vga_g1, vga_b1, vga_r2, vga_g2, vga_b2;
	
	reg [2:0] vga_r = {vga_r2, vga_r1, vga_r0};
	reg [2:0] vga_g = {vga_g2, vga_g1, vga_g0};
	reg [1:0] vga_b = {vga_b2, vga_b1};
	
	//////////////////////////////////////////////////////////////////////////////////////////
	
	/*  LOCAL SIGNALS */
	wire fsm_reset, start, ClkPort, board_clk, clk, button_clk;
	wire [3:0] fsm_update_clk_div;
	reg  fsm_update_clk;
	wire [3:0] clk_thres;
	
	BUF BUF1 (board_clk, ClkPort); 	
	BUF BUF2 (fsm_reset, Sw0);
	BUF BUF3 (start, Sw1);
	
	reg [27:0]	DIV_CLK;
	always @ (posedge board_clk, posedge reset)  
	begin : CLOCK_DIVIDER
      if (reset)
			DIV_CLK <= 0;
      else
			DIV_CLK <= DIV_CLK + 1'b1;
	end	

	assign	button_clk = DIV_CLK[18];
	assign	clk = DIV_CLK[1];
	assign 	fsm_update_clk_div = DIV_CLK[25:22];
	assign 	{St_ce_bar, St_rp_bar, Mt_ce_bar, Mt_St_oe_bar, Mt_St_we_bar} = {5'b11111};

	wire inDisplayArea;
	wire [9:0] CounterX;
	wire [9:0] CounterY;
	wire fsm_write_strobe;
	wire fsm_row_index;
	wire [2:0] fsm_output;
	wire fsm_BtnC_SCEN;

	wire [2:0] row;
	wire [2:0] col;
	
	/*
	wire [7:0] decoded_col;
	wire [7:0] decoded_row;
	
	always@(*)
		begin
			case(col)
				3'd0: decoded_col = 8'b00000001;
				3'd1: decoded_col = 8'b00000010;
				3'd2: decoded_col = 8'b00000100;
				3'd3: decoded_col = 8'b00001000;
				3'd4: decoded_col = 8'b00010000;
				3'd5: decoded_col = 8'b00100000;
				3'd6: decoded_col = 8'b01000000;
				3'd7: decoded_col = 8'b10000000;
			endcase
			case(row)
				3'd0: decoded_row = 8'b00000001;
				3'd1: decoded_row = 8'b00000010;
				3'd2: decoded_row = 8'b00000100;
				3'd3: decoded_row = 8'b00001000;
				3'd4: decoded_row = 8'b00010000;
				3'd5: decoded_row = 8'b00100000;
				3'd6: decoded_row = 8'b01000000;
				3'd7: decoded_row = 8'b10000000;
			endcase
		end
	*/
	
	assign row = CounterX/80;
	assign col = CounterY/60;

	reg [7:0] blockarray [7:0];
	
	hvsync_generator syncgen(.clk(clk), .reset(reset),.vga_h_sync(vga_h_sync), .vga_v_sync(vga_v_sync), .inDisplayArea(inDisplayArea), .CounterX(CounterX), .CounterY(CounterY));
	ee201_debouncer #(.N_dc(25)) ee201_debouncer_1 
        (.CLK(clk), .RESET(Reset), .PB(BtnC), .DPB( ), .SCEN(BtnC_SCEN), .MCEN( ), .CCEN( ));

	
	hvsync_generator syncgen(.clk(clk), .reset(reset),.vga_h_sync(vga_h_sync), .vga_v_sync(vga_v_sync), .inDisplayArea(inDisplayArea), .CounterX(CounterX), .CounterY(CounterY));
	fsm statemachine(.btn(), .updateClk(fsm_update_clk_div), .reset(fsm_reset), .val(fsm_output), .rowIndex(), .writeStrobe());
	/////////////////////////////////////////////////////////////////
	///////////////		VGA control starts here		/////////////////
	/////////////////////////////////////////////////////////////////
	reg [9:0] position;
	
	always @(posedge DIV_CLK[21])
		begin
			if(fsm_update_clk_div == clk_thres) //updating the block moving speed
				fsm_update_clk <= 1;
			else
				fsm_update_clk <= 0;
		end

	wire R = blockarray[7-row][col];
	wire G = blockarray[7-row][col];
	wire B = blockarray[7-row][col];
	
	wire R_en = R & inDisplayArea;
	wire G_en = G & inDisplayArea;
	wire B_en = B & inDisplayArea;
	
	always @(posedge clk)
	begin
		vga_r <= {R_en, R_en, R_en};
		vga_g <= {G_en, G_en, G_en};
		vga_b <= {B_en, B_en};
		if(fsm_write_strobe)
			begin
				blockarray[7-fsm_row_index] <= fsm_output;
			end
	end
	
	/////////////////////////////////////////////////////////////////
	//////////////  	  VGA control ends here 	 ///////////////////
	/////////////////////////////////////////////////////////////////
	
	/////////////////////////////////////////////////////////////////
	//////////////  	  LD control starts here 	 ///////////////////
	/////////////////////////////////////////////////////////////////
	`define QI 			2'b00
	`define QGAME_1 	2'b01
	`define QGAME_2 	2'b10
	`define QDONE 		2'b11
	
	reg [3:0] p2_score;
	reg [3:0] p1_score;
	reg [1:0] state;
	wire LD0, LD1, LD2, LD3, LD4, LD5, LD6, LD7;
	
	assign LD0 = (p1_score == 4'b1010);
	assign LD1 = (p2_score == 4'b1010);
	
	assign LD2 = start;
	assign LD4 = reset;
	
	assign LD3 = (state == `QI);
	assign LD5 = (state == `QGAME_1);	
	assign LD6 = (state == `QGAME_2);
	assign LD7 = (state == `QDONE);
	
	/////////////////////////////////////////////////////////////////
	//////////////  	  LD control ends here 	 	////////////////////
	/////////////////////////////////////////////////////////////////
	
	/////////////////////////////////////////////////////////////////
	//////////////  	  SSD control starts here 	 ///////////////////
	/////////////////////////////////////////////////////////////////
	reg 	[3:0]	SSD;
	wire 	[3:0]	SSD0, SSD1, SSD2, SSD3;
	wire 	[1:0] ssdscan_clk;
	
	assign SSD3 = 4'b1111;
	assign SSD2 = 4'b1111;
	assign SSD1 = 4'b1111;
	assign SSD0 = position[3:0];
	
	// need a scan clk for the seven segment display 
	// 191Hz (50MHz / 2^18) works well
	assign ssdscan_clk = DIV_CLK[19:18];	
	assign An0	= !(~(ssdscan_clk[1]) && ~(ssdscan_clk[0]));  // when ssdscan_clk = 00
	assign An1	= !(~(ssdscan_clk[1]) &&  (ssdscan_clk[0]));  // when ssdscan_clk = 01
	assign An2	= !( (ssdscan_clk[1]) && ~(ssdscan_clk[0]));  // when ssdscan_clk = 10
	assign An3	= !( (ssdscan_clk[1]) &&  (ssdscan_clk[0]));  // when ssdscan_clk = 11
	
	always @ (ssdscan_clk, SSD0, SSD1, SSD2, SSD3)
	begin : SSD_SCAN_OUT
		case (ssdscan_clk) 
			2'b00:
					SSD = SSD0;
			2'b01:
					SSD = SSD1;
			2'b10:
					SSD = SSD2;
			2'b11:
					SSD = SSD3;
		endcase 
	end	

	// and finally convert SSD_num to ssd
	reg [6:0]  SSD_CATHODES;
	assign {Ca, Cb, Cc, Cd, Ce, Cf, Cg, Dp} = {SSD_CATHODES, 1'b1};
	// Following is Hex-to-SSD conversion
	always @ (SSD) 
	begin : HEX_TO_SSD
		case (SSD)		
			4'b1111: SSD_CATHODES = 7'b1111111 ; //Nothing 
			4'b0000: SSD_CATHODES = 7'b0000001 ; //0
			4'b0001: SSD_CATHODES = 7'b1001111 ; //1
			4'b0010: SSD_CATHODES = 7'b0010010 ; //2
			4'b0011: SSD_CATHODES = 7'b0000110 ; //3
			4'b0100: SSD_CATHODES = 7'b1001100 ; //4
			4'b0101: SSD_CATHODES = 7'b0100100 ; //5
			4'b0110: SSD_CATHODES = 7'b0100000 ; //6
			4'b0111: SSD_CATHODES = 7'b0001111 ; //7
			4'b1000: SSD_CATHODES = 7'b0000000 ; //8
			4'b1001: SSD_CATHODES = 7'b0000100 ; //9
			4'b1010: SSD_CATHODES = 7'b0001000 ; //10 or A
			default: SSD_CATHODES = 7'bXXXXXXX ; // default is not needed as we covered all cases
		endcase
	end
	
	/////////////////////////////////////////////////////////////////
	//////////////  	  SSD control ends here 	 ///////////////////
	/////////////////////////////////////////////////////////////////
	
		/////////////////////////////////////////////////////////////////
	//////////////  	  Row Enconding control starts here 	 	////////////////////
	/////////////////////////////////////////////////////////////////
	
	
	
	
	/////////////////////////////////////////////////////////////////
	//////////////  	  Row Encoding control ends here 	 ///////////////////
	/////////////////////////////////////////////////////////////////
endmodule
