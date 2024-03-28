module apb_test_top;

	localparam ADDRESSWIDTH= 4;
	localparam DATAWIDTH= 8;
	
	reg PCLK;
	reg PRESETn;
	reg [ADDRESSWIDTH-1:0]PADDR;
	reg [DATAWIDTH-1:0] PWDATA;
	reg PWRITE;
	reg PSELx;
	reg PENABLE;
	wire  [DATAWIDTH-1:0] PRDATA;
	wire  PREADY;
	
	wire i2c_sda;
	wire i2c_scl;
	
	reg clk;

	apb_to_i2c_top dut(
		.PCLK(PCLK), 
		.PRESETn(PRESETn), 
		.PADDR(PADDR), 
		.PWDATA(PWDATA), 
		.PWRITE(PWRITE), 
		.PSELx(PSELx), 
		.PENABLE(PENABLE), 
		.PRDATA(PRDATA),
		.PREADY(PREADY),
		
		.i2c_sda(i2c_sda), 
		.i2c_scl(i2c_scl), 
		.clk(clk)
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
		PWDATA = 8'b00100000;
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
		PWDATA = 8'b10101010;
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
		PWDATA = 8'b00001111;
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
		PWDATA = 8'b11001100;
		PWRITE = 1; 
		PSELx = 1;
		#2
		PENABLE = 1;
		#2
		PENABLE = 0;
		PSELx = 0;
		//test
		//transmit data 4
		#2
		PADDR = 4;
		PWDATA = 8'b00011110;
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
		PWDATA = 8'b10101110;
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
		/*//transmit i2c_enable 
		#200
		PADDR = 2;
		PWDATA = 8'b11111100;
		PWRITE = 1; 
		PSELx = 1;
		#2
		PENABLE = 1;
		#2
		PENABLE = 0;
		PSELx = 0;
		#116
		sda_in = 0;
		#16
		sda_in = 1;*/
		//transmit address
		#250
		PADDR = 6;
		PWDATA = 8'b01010101;
		PWRITE = 1; 
		PSELx = 1;
		#2
		PENABLE = 1;
		#2
		PENABLE = 0;
		PSELx = 0;
		//receive data
		#250
		PADDR = 5;
		PWDATA = 8'b01010101;
		PWRITE = 0; 
		PSELx = 1;
		#2
		PENABLE = 1;
		#2
		PENABLE = 0;
		PSELx = 0;
		#1000
		$finish;
	end   
	
endmodule