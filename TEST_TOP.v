`timescale 1ns/1ns
module test_top;

	localparam ADDRESSWIDTH= 4;
	localparam DATAWIDTH= 8;
	
	reg PCLK;
	reg PRESETn;
	reg [ADDRESSWIDTH-1:0]PADDR;
	reg [DATAWIDTH-1:0] PWDATA;
	reg PWRITE;
	reg PSELx;
	reg PENABLE;
	wire [DATAWIDTH-1:0] PRDATA;
	wire PREADY;
		
	reg reset;
	reg clk;
	reg channel_format; //0: serial, 1: enhanced
	reg optional_pause;
	reg config_bit;
	reg enable;
	reg [3:0] id_4bit;
	reg [7:0] id_8bit;
	reg [11:0] data_12bit;
	reg [15:0] data_16bit;
	reg [7:0] data_short;
		
	reg clk_rx;
		//output
		wire [3:0] data_nibble_rx;
		wire sync_rx;
		wire pause_rx;
		wire channel_error;
		wire data_check_ticks;

	top dut(
		.PCLK(PCLK),
		.PRESETn(PRESETn),
		.PADDR(PADDR),
		.PWDATA(PWDATA),
		.PWRITE(PWRITE),
		.PSELx(PSELx),
		.PENABLE(PENABLE),
		.PRDATA(PRDATA),
		.PREADY(PREADY),
		
		.reset(reset),
		.clk(clk),
		.channel_format(channel_format), //0: serial, 1: enhanced
		.optional_pause(optional_pause),
		.config_bit(config_bit),
		.enable(enable),
		.id_4bit(id_4bit),
		.id_8bit(id_8bit),
		.data_12bit(data_12bit),
		.data_16bit(data_16bit),
		.data_short(data_short),
		
		//wire
		.clk_rx(clk_rx),
		.data_nibble_rx(data_nibble_rx)
	);


	initial begin
		PCLK = 0;
		forever begin
			PCLK = #1 ~PCLK;
		end		
	end
	initial begin
		clk = 0;
		forever begin
			clk = #2 ~clk;
		end		
	end
	initial begin
		clk_rx = 0;
		forever begin
			clk_rx = #2 ~clk_rx;
		end		
	end
	initial begin
		reset = 1;
		PCLK = 0;
		PRESETn = 0;
		PADDR = 0;
		PWDATA = 0;
		PWRITE = 0; 
		PSELx = 0;
		PENABLE = 0;
		#5
       		PRESETn = 1;
		 //transmit RESET
		
		#2
		PADDR = 2;
		PWDATA = 8'b11110100;
		PWRITE = 1; 
		PSELx = 1;
		#2
		PENABLE = 1;
		#2
		PENABLE = 0;
		PSELx = 0; 
		//transmit address
		
		#2
		PADDR = 6;
		PWDATA = 8'h01;
		PWRITE = 1; 
		PSELx = 1;
		#2
		PENABLE = 1;
		#2
		PENABLE = 0;
		PSELx = 0;
		//transmit data 1
		#2
		PADDR = 6;
		PWDATA = 8'h01;
		PWRITE = 1; 
		PSELx = 1;
		#2
		PENABLE = 1;
		#2
		PENABLE = 0;
		PSELx = 0;	
		//transmit data 1
		#2
		PADDR = 6;
		PWDATA = 8'h02;
		PWRITE = 1; 
		PSELx = 1;
		#2
		PENABLE = 1;
		#2
		PENABLE = 0;
		PSELx = 0;	
		//transmit data 1
		#2
		PADDR = 6;
		PWDATA = 8'h03;
		PWRITE = 1; 
		PSELx = 1;
		#2
		PENABLE = 1;
		#2
		PENABLE = 0;
		PSELx = 0;	
		//transmit data 1
		#2
		PADDR = 6;
		PWDATA = 8'h04;
		PWRITE = 1; 
		PSELx = 1;
		#2
		PENABLE = 1;
		#2
		PENABLE = 0;
		PSELx = 0;	

		//transmit data 1
		#2
		PADDR = 6;
		PWDATA = 8'h05;
		PWRITE = 1; 
		PSELx = 1;
		#2
		PENABLE = 1;
		#2
		PENABLE = 0;
		PSELx = 0;	
		//reset		
		reset = 0;
		//transmit data 1
		#2
		PADDR = 6;
		PWDATA = 8'h06;
		PWRITE = 1; 
		PSELx = 1;
		#2
		PENABLE = 1;
		#2
		PENABLE = 0;
		PSELx = 0;	
		//transmit data 1
		#2
		PADDR = 6;
		PWDATA = 8'h07;
		PWRITE = 1; 
		PSELx = 1;
		#2
		PENABLE = 1;
		#2
		PENABLE = 0;
		PSELx = 0;	

		//transmit data 1
		#2
		PADDR = 6;
		PWDATA = 8'h08;
		PWRITE = 1; 
		PSELx = 1;
		#2
		PENABLE = 1;
		#2
		PENABLE = 0;
		PSELx = 0;	
		//transmit data 2 
		#2
		PADDR = 6;
		PWDATA = 8'h09;
		PWRITE = 1; 
		PSELx = 1;
		#2
		PENABLE = 1;
		#2
		PENABLE = 0;
		PSELx = 0;
		//transmit data 3
		#2
		PADDR = 6;
		PWDATA = 8'h0a;
		PWRITE = 1; 
		PSELx = 1;
		#2
		PENABLE = 1;
		#2
		PENABLE = 0;
		PSELx = 0;
		//transmit data 4
		#2
		PADDR = 6;
		PWDATA = 8'h0b;
		PWRITE = 1; 
		PSELx = 1;
		#2
		PENABLE = 1;
		#2
		PENABLE = 0;
		PSELx = 0;
		//transmit data 5
		#2
		PADDR = 6;
		PWDATA = 8'h0c;
		PWRITE = 1; 
		PSELx = 1;
		#2
		PENABLE = 1;
		#2
		PENABLE = 0;
		PSELx = 0;
		//transmit data 6
		#2
		PADDR = 6;
		PWDATA = 8'h0d;
		PWRITE = 1; 
		PSELx = 1;
		#2
		PENABLE = 1;
		#2
		PENABLE = 0;
		PSELx = 0;
		//transmit data 7
		#2
		PADDR = 6;
		PWDATA = 8'h0e;
		PWRITE = 1; 
		PSELx = 1;
		#2
		PENABLE = 1;
		#2
		PENABLE = 0;
		PSELx = 0;
		//transmit data 8
		#2
		PADDR = 6;
		PWDATA = 8'h0f;
		PWRITE = 1; 
		PSELx = 1;
		#2
		PENABLE = 1;
		#2
		PENABLE = 0;
		PSELx = 0;
		//transmit data 1
		#2
		PADDR = 4;
		PWDATA = 8'h01;
		PWRITE = 1; 
		PSELx = 1;
		#2
		PENABLE = 1;
		#2
		PENABLE = 0;
		PSELx = 0;	
		//transmit data 1
		#2
		PADDR = 4;
		PWDATA = 8'h02;
		PWRITE = 1; 
		PSELx = 1;
		#2
		PENABLE = 1;
		#2
		PENABLE = 0;
		PSELx = 0;	
		//transmit data 1
		#2
		PADDR = 4;
		PWDATA = 8'h03;
		PWRITE = 1; 
		PSELx = 1;
		#2
		PENABLE = 1;
		#2
		PENABLE = 0;
		PSELx = 0;	
		//transmit data 1
		#2
		PADDR = 4;
		PWDATA = 8'h04;
		PWRITE = 1; 
		PSELx = 1;
		#2
		PENABLE = 1;
		#2
		PENABLE = 0;
		PSELx = 0;	

		//transmit data 1
		#2
		PADDR = 4;
		PWDATA = 8'h05;
		PWRITE = 1; 
		PSELx = 1;
		#2
		PENABLE = 1;
		#2
		PENABLE = 0;
		PSELx = 0;	
		//reset		
		reset = 0;
		//transmit data 1
		#2
		PADDR = 4;
		PWDATA = 8'h06;
		PWRITE = 1; 
		PSELx = 1;
		#2
		PENABLE = 1;
		#2
		PENABLE = 0;
		PSELx = 0;	
		//transmit data 1
		#2
		PADDR = 4;
		PWDATA = 8'h07;
		PWRITE = 1; 
		PSELx = 1;
		#2
		PENABLE = 1;
		#2
		PENABLE = 0;
		PSELx = 0;	

		//transmit data 1
		#2
		PADDR = 4;
		PWDATA = 8'h08;
		PWRITE = 1; 
		PSELx = 1;
		#2
		PENABLE = 1;
		#2
		PENABLE = 0;
		PSELx = 0;	
		//transmit data 2 
		#2
		PADDR = 4;
		PWDATA = 8'h09;
		PWRITE = 1; 
		PSELx = 1;
		#2
		PENABLE = 1;
		#2
		PENABLE = 0;
		PSELx = 0;
		//transmit data 3
		#2
		PADDR = 4;
		PWDATA = 8'h0a;
		PWRITE = 1; 
		PSELx = 1;
		#2
		PENABLE = 1;
		#2
		PENABLE = 0;
		PSELx = 0;
		//transmit data 4
		#2
		PADDR = 4;
		PWDATA = 8'h0b;
		PWRITE = 1; 
		PSELx = 1;
		#2
		PENABLE = 1;
		#2
		PENABLE = 0;
		PSELx = 0;
		//transmit data 5
		#2
		PADDR = 4;
		PWDATA = 8'h0c;
		PWRITE = 1; 
		PSELx = 1;
		#2
		PENABLE = 1;
		#2
		PENABLE = 0;
		PSELx = 0;
		//transmit data 6
		#2
		PADDR = 4;
		PWDATA = 8'h0d;
		PWRITE = 1; 
		PSELx = 1;
		#2
		PENABLE = 1;
		#2
		PENABLE = 0;
		PSELx = 0;
		//transmit data 7
		#2
		PADDR = 4;
		PWDATA = 8'h0e;
		PWRITE = 1; 
		PSELx = 1;
		#2
		PENABLE = 1;
		#2
		PENABLE = 0;
		PSELx = 0;
		//transmit data 8
		#2
		PADDR = 4;
		PWDATA = 8'h0f;
		PWRITE = 1; 
		PSELx = 1;
		#2
		PENABLE = 1;
		#2
		PENABLE = 0;
		PSELx = 0;
		//transmit data 8
		#2
		PADDR = 4;
		PWDATA = 8'h10;
		PWRITE = 1; 
		PSELx = 1;
		#2
		PENABLE = 1;
		#2
		PENABLE = 0;
		PSELx = 0;
		//transmit data 8
		#2
		PADDR = 4;
		PWDATA = 8'h11;
		PWRITE = 1; 
		PSELx = 1;
		#2
		PENABLE = 1;
		#2
		PENABLE = 0;
		PSELx = 0;

		//transmit data 8
		#2
		PADDR = 4;
		PWDATA = 8'h12;
		PWRITE = 1; 
		PSELx = 1;
		#2
		PENABLE = 1;
		#2
		PENABLE = 0;
		PSELx = 0;
		//transmit data 8
		#2
		PADDR = 4;
		PWDATA = 8'h13;
		PWRITE = 1; 
		PSELx = 1;
		#2
		PENABLE = 1;
		#2
		PENABLE = 0;
		PSELx = 0;
		//transmit data 8
		#2
		PADDR = 4;
		PWDATA = 8'h14;
		PWRITE = 1; 
		PSELx = 1;
		#2
		PENABLE = 1;
		#2
		PENABLE = 0;
		PSELx = 0;
		//transmit data 8
		#2
		PADDR = 4;
		PWDATA = 8'h15;
		PWRITE = 1; 
		PSELx = 1;
		#2
		PENABLE = 1;
		#2
		PENABLE = 0;
		PSELx = 0;
		//transmit i2c_enable
		#2
		PADDR = 2;
		PWDATA = 8'b11111100;
		PWRITE = 1; 
		PSELx = 1;
		#2
		PENABLE = 1;
		#2
		PENABLE = 0;
		PSELx = 0;
		//transmit i2c_enable 
		id_4bit = 4'b1010;
		id_8bit = 8'h55;
		data_12bit = 12'h123;
		data_16bit = 16'h 1234;
		data_short = 8'h01;
		optional_pause = 0;
		config_bit = 0;
		channel_format = 1;
		#10;
		enable = 1;
		#50
		enable = 0;
		#65000;
		#10;
		enable = 1;
		#50
		enable = 0;
		#65000;
		$finish;
	end   
endmodule
