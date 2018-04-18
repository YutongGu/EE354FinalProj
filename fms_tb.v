`timescale 1ns / 1ps

module fsm_tb_v;

		// Inputs
	reg btn;
	reg reset;
	reg start;
	reg ack_tb;
	reg [7:0] rowRead;
	reg updateClk;
	reg Reset;
	reg clk_tb;

	// Outputs
	wire [7:0] val;
	wire rowWrite;
	wire writeStrobe;
	wire level;
	reg [6*8:0] state_string; // 6-character string for symbolic display of state
	
	// Instantiate the Unit Under Test (UUT)
	fsm  UUT  
	(.rowRead(rowRead),
    .btn(btn),
    .updateClk(updateClk),
	 .reset(Reset),
    .val(val),
    .rowWrite(rowWrite),
    .writeStrobe(writeStrobe),
    .level(level)
    );
	
	initial 
		begin: CLK_GEN
			clk_tb = 0;
			forever
				begin
					#10 clk_tb = ~ clk_tb;
					updateClk = clk_tb;
				end
		end: CLK_GEN
	
	initial
		begin: INPUTS
			reset = 0;
			start = 0;
			ack_tb = 0;
			rowRead = 8'b00000000;
			clk_tb = 0;
						
			//wait for global reset
			// Wait 100 ns for global reset to finish
			#103;
			
			START();
			
			@(posedge clk_tb)
			@(posedge clk_tb)
			@(posedge clk_tb)
			@(posedge clk_tb)
			@(posedge clk_tb)
			@(posedge clk_tb)
			@(posedge clk_tb)
			@(posedge clk_tb)
			@(posedge clk_tb)
			@(posedge clk_tb)
			HIT_BTN();
			
		end
	task SEND_ACK;
	begin
		ack_tb = 1;
		@ (posedge clk_tb)
		ack_tb = 0;
	end
	endtask

	task HIT_BTN;
	begin
		btn = 1;
		@ (posedge clk_tb)
		@ (posedge clk_tb)
		@ (posedge clk_tb)
		btn = 0;
	end
	endtask
		
	task START;
	begin
		start = 1;
		@ (posedge clk_tb)
		start = 0;
	end
	endtask
	
	task RESET;
		begin
		reset = 1;
		@ (posedge clk_tb)
		reset = 0;
	end
	endtask
endmodule