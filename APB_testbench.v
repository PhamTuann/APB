module apb_testbench;

	parameter ADDRESSWIDTH= 32;
	parameter DATAWIDTH= 8;
	
	reg PCLK;
	reg PRESETn;
	reg [ADDRESSWIDTH-1:0]PADDR;
	reg [DATAWIDTH-1:0] PWDATA;
	reg PWRITE;
	reg PSELx;
	reg PENABLE;
	wire [DATAWIDTH-1:0] PRDATA;
	wire PREADY;

	apb_slave dut(
		.PCLK(PCLK), 
		.PRESETn(PRESETn), 
		.PADDR(PADDR), 
		.PWDATA(PWDATA), 
		.PWRITE(PWRITE), 
		.PSELx(PSELx), 
		.PENABLE(PENABLE), 
		.PRDATA(PRDATA),
		.PREADY(PREADY)
	);

	initial begin
		PCLK = 0;
		forever begin
			PCLK = #1 ~PCLK;
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
		#12
		//T1
		PADDR = 8'b110101010;
		PWDATA = 8'b11110000;
		PWRITE = 1; 
		PSELx = 1;
		#5
		//T2
		PENABLE = 1; 
		#15
		PENABLE = 1; 
		PWRITE = 0;
		PSELx = 0;
		#15
		PENABLE = 0; 
		PWRITE = 0;
		PSELx = 0;
		#200
		$finish;
	end    

endmodule
