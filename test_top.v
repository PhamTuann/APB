module apb_to_i2c 
	#(localparam ADDRESSWIDTH= 4,
	localparam DATAWIDTH= 32)

	(
	input PCLK,
	input PRESETn,
	input [ADDRESSWIDTH-1:0]PADDR,
	input [DATAWIDTH-1:0] PWDATA,
	input PWRITE,
	input PSELx,
	input PENABLE,
	output  [DATAWIDTH-1:0] PRDATA,
	output  PREADY,
	
	output i2c_sda,
	output i2c_scl,
	input clk,
	input i2c_reset,
	input i2c_enable
	);
	
	wire [7:0] reg_command;
	wire [7:0] reg_status;
	wire [31:0] reg_transmit;
	wire [31:0] reg_receive;	

	wire [31:0] data_fifo_to_i2c;
	wire [31:0] data_i2c_to_fifo;

	apb_slave apb_slave(
		.PCLK(PCLK),
		.PRESETn(PRESETn),
		.PADDR(PADDR),
		.PWDATA(PWDATA),
		.PWRITE(PWRITE),
		.PSELx(PSELx),
		.PENABLE(PENABLE),
		.PRDATA(PRDATA),
		.PREADY(PREADY),
	
		//register	
		.reg_command(reg_command),
		.reg_status(reg_status),
		.reg_transmit(reg_transmit),
		.reg_receive(reg_receive)
	);

	async_fifo tx_fifo(
		.write_enable(reg_command[6]), 
		.write_clk(PCLK), 
		.write_reset_n(reg_command[7]),
		.read_enable(reg_command[4]), 
		.read_clk(clk), 
		.read_reset_n(reg_command[5]),
		.write_data(reg_transmit),
		.read_data(data_fifo_to_i2c),
		.write_full(reg_status[7]),
		.read_empty(reg_status[6])
	);

	async_fifo rx_fifo(
		.write_enable(reg_command[2]), 
		.write_clk(PCLK), 
		.write_reset_n(reg_command[3]),
		.read_enable(reg_command[0]), 
		.read_clk(clk), 
		.read_reset_n(reg_command[1]),
		.write_data(data_i2c_to_fifo),
		.read_data(reg_receive),
		.write_full(reg_status[5]),
		.read_empty(reg_status[4])
	);

	i2c_master i2c_master(
		.clk(clk),
		.i2c_reset(i2c_reset),
		.addr(data_fifo_to_i2c[15:9]),
		.rw(data_fifo_to_i2c[8]),
		.i2c_enable(i2c_enable),
		.i2c_data_in(data_fifo_to_i2c[7:0]),
		.i2c_data_out(data_i2c_to_fifo),
		.i2c_sda(i2c_sda),
		.i2c_scl(i2c_scl),
		.i2c_ready(reg_status[3])
	);
	
	
endmodule