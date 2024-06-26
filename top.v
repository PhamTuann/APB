module apb_to_i2c_top 
	#(parameter ADDRESSWIDTH= 4,
	parameter DATAWIDTH= 8)

	(
	//apb block
	input PCLK,
	input PRESETn,
	input [ADDRESSWIDTH-1:0] PADDR,
	input [DATAWIDTH-1:0] PWDATA,
	input PWRITE,
	input PSELx,
	input PENABLE,
	output  [DATAWIDTH-1:0] PRDATA,
	output  PREADY,
	
	//i2c block
	inout i2c_sda,
	inout i2c_scl,
	input clk
	

	);
	
	//apb signal
	wire write_enable_tx;
	wire read_enable_rx;
	wire delete_reg_command;

	//register apb
	wire [7:0] reg_command;
	wire [7:0] reg_status;
	wire [7:0] reg_transmit;
	wire [7:0] reg_receive;	
	wire [7:0] reg_address;
	
	//change 1 bit to 8 bit data out
	wire [7:0] combine_bit_data;
	
	//
	wire [7:0] data_fifo_to_i2c;
	wire [7:0] data_i2c_to_fifo;
	reg [7:0] data_fifo_to_i2c_tx;
	
	//i2c signal
	wire i2c_ready;
	wire [7:0] i2c_data_in;
	wire fifo_tx_rd_en;
	wire fifo_rx_wr_en;
	wire i2c_enable;
	wire fifo_tx_empty;
	
	//signal
	reg [7:0] pre_i2c_data_in;
	reg delete_i2c_enable;
	reg pre_i2c_enable;
	reg [2:0] status1 = 0;
	reg c = 0;
	reg pre_data_i2c_to_fifo;

	// bit no use
	assign reg_command[0] = 1'b0;
	assign reg_status[2:0] = 3'b000;
	
	//connect module
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
		.reg_receive(reg_receive),
		.reg_address(reg_address),

		.write_enable_tx(write_enable_tx),
		.read_enable_rx(read_enable_rx),
		.delete_reg_command(delete_reg_command)
	);

	async_fifo tx_fifo(
		.write_enable(write_enable_tx), 
		.write_clk(PCLK), 
		.write_reset_n(reg_command[7]),
		.read_enable(fifo_tx_rd_en), 
		.read_clk(clk), 
		.read_reset_n(reg_command[6]),
		.write_data(reg_transmit),
		.read_data(data_fifo_to_i2c),
		.write_full(reg_status[7]),
		.read_empty(reg_status[6])
	);

	async_fifo rx_fifo(
		.write_enable(fifo_rx_wr_en), 
		.write_clk(clk), 
		.write_reset_n(reg_command[5]),
		.read_enable(read_enable_rx), 
		.read_clk(PCLK), 
		.read_reset_n(reg_command[4]),
		.write_data(data_i2c_to_fifo),
		.read_data(reg_receive),
		.write_full(reg_status[5]),
		.read_empty(reg_status[4])
	);

	i2c_master i2c_master(
		.clk(clk),
		.i2c_reset_n(reg_command[3]),
		.addr(reg_address[7:1]),
		.rw(reg_address[0]),
		.i2c_enable(i2c_enable),
		.i2c_data_in(i2c_data_in),
		.i2c_data_out(data_i2c_to_fifo),
		.i2c_sda(i2c_sda),
		.i2c_scl(i2c_scl),
		.i2c_ready(reg_status[3]),
		.fifo_tx_rd_en(fifo_tx_rd_en),
		.fifo_rx_wr_en(fifo_rx_wr_en),
		.i2c_repeat_start(reg_command[1]),
		.fifo_tx_empty(reg_status[6]),
		.fifo_rx_full(reg_status[5])
	);

	i2c_slave_model i2c_slave(
		.sda(i2c_sda),
		.scl(i2c_scl)
	);
	
	// fifo_tx_rd_en -> read accept
	assign i2c_data_in = pre_i2c_data_in;
	always@ (posedge clk) begin
		if (fifo_tx_rd_en)
			pre_i2c_data_in <= data_fifo_to_i2c;
	end

	assign delete_reg_command = c; 
	always@ (posedge clk) begin
		if (reg_command[2] && !reg_status[3]) begin
			c <= 1;
		end
		else c <= 0;
			
	end
	assign i2c_enable = pre_i2c_enable;
	always@ (posedge clk) begin
		if(reg_command[2] == 1) begin
			if (reg_status[3]) begin
				pre_i2c_enable <= reg_command[2];
				end
			else begin
				pre_i2c_enable <= 0;
			end
		end
	end
	
endmodule