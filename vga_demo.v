`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// VGA verilog template
// Author:  Da Cheng
//////////////////////////////////////////////////////////////////////////////////
module vga_demo(ClkPort, vga_h_sync, vga_v_sync, vga_r0, vga_g0, vga_r1, vga_g1, 
	vga_b1, vga_r2, vga_g2, vga_b2, Sw6, Sw7, BtnC, BtnD,
	St_ce_bar, St_rp_bar, Mt_ce_bar, Mt_St_oe_bar, Mt_St_we_bar,
	An0, An1, An2, An3, Ca, Cb, Cc, Cd, Ce, Cf, Cg, Dp,
	LD0, LD1, LD2, LD3, LD4, LD5, LD6, LD7);
	
	input ClkPort, BtnC, BtnD, Sw6, Sw7;
	output St_ce_bar, St_rp_bar, Mt_ce_bar, Mt_St_oe_bar, Mt_St_we_bar;
	output vga_h_sync, vga_v_sync, vga_r0, vga_g0, vga_r1, vga_g1, vga_b1, vga_r2, vga_g2, vga_b2;
	output An0, An1, An2, An3, Ca, Cb, Cc, Cd, Ce, Cf, Cg, Dp;
	output LD0, LD1, LD2, LD3, LD4, LD5, LD6, LD7;
	
	wire [1:0] 	ssdscan_clk;
	reg [3:0]	SSD;
	wire [3:0]	SSD3, SSD2, SSD1, SSD0;
	reg [7:0]  	SSD_CATHODES;
	
	wire [1:0] 	colorschm;
	
	reg [2:0] vga_r;
	reg [2:0] vga_g;
	reg [1:0] vga_b;
	
	assign vga_r2 = vga_r[2];
	assign vga_r1 = vga_r[1];
	assign vga_r0 = vga_r[0];
	assign vga_g2 = vga_g[2];
	assign vga_g1 = vga_g[1];
	assign vga_g0 = vga_g[0];
	assign vga_b2 = vga_b[1];
	assign vga_b1 = vga_b[0];
	
	assign colorschm = {Sw6, Sw7};
	
	//////////////////////////////////////////////////////////////////////////////////////////
	
	/*  LOCAL SIGNALS */
	wire reset, ClkPort, board_clk, clk;
	reg [3:0] fsm_update_clk_div;
	reg  fsm_update_clk;
	wire [3:0] clk_thres;
	
	BUF BUF1 (board_clk, ClkPort); 	
	BUF BUF2 (reset, BtnD);
	
	assign LD0 = BtnC;
	assign LD1 = fsm_BtnC_SCEN;
	
	reg [27:0]	DIV_CLK;
	always @ (posedge board_clk, posedge reset)  
	begin : CLOCK_DIVIDER
      if (reset)
			DIV_CLK <= 0;
      else
			DIV_CLK <= DIV_CLK + 1'b1;
	end	

	assign	clk = DIV_CLK[1];
	
	assign 	{St_ce_bar, St_rp_bar, Mt_ce_bar, Mt_St_oe_bar, Mt_St_we_bar} = {5'b11111};

	wire inDisplayArea;
	wire [9:0] CounterX;
	wire [9:0] CounterY;
	wire fsm_write_strobe;
	wire [2:0] fsm_row_index;
	wire [7:0] fsm_output;
	wire fsm_clrarray;
	wire fsm_BtnC_SCEN;
	
	assign clk_thres = 4'd10 - {1'b0,fsm_row_index};

	wire [2:0] row;
	wire [2:0] col;
	
	assign col = CounterX/80;
	assign row = CounterY/60;

	reg [7:0] blockarray [7:0];
	
	wire [2:0] fsm_state;
	
	hvsync_generator syncgen(.clk(clk), .reset(reset),.vga_h_sync(vga_h_sync), .vga_v_sync(vga_v_sync), 
		.inDisplayArea(inDisplayArea), .CounterX(CounterX), .CounterY(CounterY));
		
	ee201_debouncer #(.N_dc(15)) ee201_debouncer_1 
        (.CLK(clk), .RESET(reset), .PB(BtnC), .DPB( ), .SCEN(fsm_BtnC_SCEN), .MCEN( ), .CCEN( ));

	fsm statemachine(.clk(clk), .btn(fsm_BtnC_SCEN), .updateClk(fsm_update_clk), .reset(reset), .val(fsm_output), 
		.rowIndex(fsm_row_index), .writeStrobe(fsm_write_strobe), .clrarray(fsm_clrarray), .state(fsm_state));
	/////////////////////////////////////////////////////////////////
	///////////////		VGA control starts here		/////////////////
	/////////////////////////////////////////////////////////////////

	wire R = blockarray[row][7-col];
	wire G = blockarray[row][7-col];
	wire B = blockarray[row][7-col];
	
	wire R_en = R & inDisplayArea;
	wire G_en = G & inDisplayArea;
	wire B_en = B & inDisplayArea;
	
	reg update_flag;
	reg [2:0] rval_on;
	reg [2:0] gval_on;
	reg [1:0] bval_on;
	reg [2:0] rval_off;
	reg [2:0] gval_off;
	reg [1:0] bval_off;
	
	always @(posedge clk)
	begin
	
		if(R_en)
			vga_r <= rval_on;
		else
			vga_r <= rval_off;
			
		if(G_en)
			vga_g <= gval_on;
		else
			vga_g <= gval_off;
			
		if(B_en)
			vga_b <= bval_on;
		else
			vga_b <= bval_off;
		
		if((fsm_update_clk_div == clk_thres) & (update_flag == 0)) //updating the block moving speed
			begin
				fsm_update_clk <= 1;
				update_flag <= 1;
				
			end
		else
			fsm_update_clk <= 0;
			
		if(fsm_clrarray)
			begin
				blockarray[0] <= 7'd0;
				blockarray[1] <= 7'd0;
				blockarray[2] <= 7'd0;
				blockarray[3] <= 7'd0;
				blockarray[4] <= 7'd0;
				blockarray[5] <= 7'd0;
				blockarray[6] <= 7'd0;
				blockarray[7] <= 7'd0;
			end
			
		if(fsm_update_clk_div != clk_thres)
			update_flag <=0;
			
		if(fsm_write_strobe)
			begin
				blockarray[7-fsm_row_index] <= fsm_output;
			end
			
		case(colorschm)
			2'b00: 
				begin
					rval_on <= 3'b111;
					rval_off <= 3'b000;
					gval_on <= 3'b111;
					gval_off <= 3'b000;
					bval_on <= 2'b11;
					bval_off <= 2'b00;
				end
			2'b01:
				begin
					rval_on <= 3'b000;
					rval_off <= 3'b111;
					gval_on <= 3'b000;
					gval_off <= 3'b111;
					bval_on <= 2'b00;
					bval_off <= 2'b11;
				end
			2'b10:
				begin
					rval_on <= 3'b111;
					rval_off <= 3'b111;
					gval_on <= 3'b111;
					gval_off <= 3'b001;
					bval_on <= 2'b01;
					bval_off <= 2'b01;
				end
			2'b11:
				begin
					rval_on <= 3'b111;
					rval_off <= 3'b111;
					gval_on <= 3'b001;
					gval_off <= 3'b111;
					bval_on <= 2'b01;
					bval_off <= 2'b01;
				end
		endcase
	end
	
	reg btnflag;
	
	always@(posedge DIV_CLK[21] or posedge fsm_BtnC_SCEN)
	begin
		if(fsm_BtnC_SCEN)
			fsm_update_clk_div <= 0;
		else
			if(fsm_update_clk_div == clk_thres)
				fsm_update_clk_div <= 0;
			else
				fsm_update_clk_div <= fsm_update_clk_div + 1;	
				
	end
	
	
	/////////////////////////////////////////////////////////////////
	//////////////  	  VGA control ends here 	 ///////////////////
	/////////////////////////////////////////////////////////////////
	
	/////////////////////////////////////////////////////////////////
	//////////////  	  LD control starts here 	 ///////////////////
	/////////////////////////////////////////////////////////////////
	/*
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
	*/
	
	assign SSD3 = rval_on;
	assign SSD2 = rval_off;
	assign SSD1 = gval_on;
	assign SSD0 = gval_off;
	assign ssdscan_clk = DIV_CLK[19:18];

	
	assign An0	= !(~(ssdscan_clk[1]) && ~(ssdscan_clk[0]));  // when ssdscan_clk = 00
	assign An1	= !(~(ssdscan_clk[1]) &&  (ssdscan_clk[0]));  // when ssdscan_clk = 01
	assign An2	=  !((ssdscan_clk[1]) && ~(ssdscan_clk[0]));  // when ssdscan_clk = 10
	assign An3	=  !((ssdscan_clk[1]) &&  (ssdscan_clk[0]));  // when ssdscan_clk = 11
	
	
	always @ (ssdscan_clk, SSD0, SSD1, SSD2, SSD3)
	begin : SSD_SCAN_OUT
		case (ssdscan_clk) 
				  2'b00: SSD = SSD0;
				  2'b01: SSD = SSD1;
				  2'b10: SSD = SSD2;
				  2'b11: SSD = SSD3;
		endcase 
	end

	// Following is Hex-to-SSD conversion
	always @ (SSD) 
	begin : HEX_TO_SSD
		case (SSD) // in this solution file the dot points are made to glow by making Dp = 0
		    //                                                                abcdefg,Dp
			4'b0000: SSD_CATHODES = 8'b00000010; // 0
			4'b0001: SSD_CATHODES = 8'b10011110; // 1
			4'b0010: SSD_CATHODES = 8'b00100100; // 2
			4'b0011: SSD_CATHODES = 8'b00001100; // 3
			4'b0100: SSD_CATHODES = 8'b10011000; // 4
			4'b0101: SSD_CATHODES = 8'b01001000; // 5
			4'b0110: SSD_CATHODES = 8'b01000000; // 6
			4'b0111: SSD_CATHODES = 8'b00011110; // 7
			4'b1000: SSD_CATHODES = 8'b00000000; // 8
			4'b1001: SSD_CATHODES = 8'b00001000; // 9
			4'b1010: SSD_CATHODES = 8'b00010000; // A
			4'b1011: SSD_CATHODES = 8'b11000000; // B
			4'b1100: SSD_CATHODES = 8'b01100010; // C
			4'b1101: SSD_CATHODES = 8'b10000100; // D
			4'b1110: SSD_CATHODES = 8'b01100000; // E
			4'b1111: SSD_CATHODES = 8'b01110000; // F    
			default: SSD_CATHODES = 8'bXXXXXXXX; // default is not needed as we covered all cases
		endcase
	end	
	
	// reg [7:0]  SSD_CATHODES;
	assign {Ca, Cb, Cc, Cd, Ce, Cf, Cg, Dp} = {SSD_CATHODES};
	
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
