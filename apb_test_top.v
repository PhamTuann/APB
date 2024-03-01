module apb_testbench_tb;

	localparam ADDRESSWIDTH= 4;
	localparam DATAWIDTH= 32;
	
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
	reg i2c_reset;
	reg i2c_enable;

	apb_to_i2c dut(
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
		.clk(clk),
		.i2c_reset(i2c_reset),
		.i2c_enable(i2c_enable)
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
		i2c_reset = 1;
		i2c_enable = 0;
		#1
       		PRESETn = 1;
		i2c_reset = 0;
		
		//transmit command
		#2
		PADDR = 2;
		PWDATA = 8'b00000000;
		PWRITE = 1; 
		PSELx = 1;
		#2
		PENABLE = 1;
		#2
		PENABLE = 0;
		PSELx = 0;
		//transmit data
		#2
		PADDR = 4;
		PWDATA = 16'b0101010010101010;
		PWRITE = 1; 
		PSELx = 1;
		#2
		PENABLE = 1;
		#2
		PENABLE = 0;
		PSELx = 0;
		//transmit cmd
		#2
		PADDR = 2;
		PWDATA = 8'b11110000;
		PWRITE = 1; 
		PSELx = 1;
		#2
		PENABLE = 1;
		#2
		PENABLE = 0;
		PSELx = 0;
		i2c_enable = 1;
		//transmit cmd
		#2
		PADDR = 2;
		PWDATA = 8'b10110000;
		PWRITE = 1; 
		PSELx = 1;
		#2
		PENABLE = 1;
		#2
		PENABLE = 0;
		PSELx = 0;
		#15
		i2c_enable = 0;
		//#2
		//transmit data
		#2
		PADDR = 4;
		PWDATA = 16'b1111000010101010;
		PWRITE = 1; 
		PSELx = 1;
		#2
		PENABLE = 1;
		#2
		PENABLE = 0;
		PSELx = 0;
		//transmit cmd
		#2
		PADDR = 2;
		PWDATA = 8'b11110000;
		PWRITE = 1; 
		PSELx = 1;
		#2
		PENABLE = 1;
		#2
		PENABLE = 0;
		PSELx = 0;
		i2c_enable = 0;
		//transmit cmd
		#2
		PADDR = 2;
		PWDATA = 8'b10110000;
		PWRITE = 1; 
		PSELx = 1;
		#2
		PENABLE = 1;
		#2
		PENABLE = 0;
		PSELx = 0;
		#15
		i2c_enable = 0;
		
		#1000
		$finish;
	end   
	
endmodule