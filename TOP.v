module top
	#(parameter ADDRESSWIDTH= 4,
	parameter DATAWIDTH= 8)
	(
		input PCLK,
		input PRESETn,
		input [ADDRESSWIDTH-1:0]PADDR,
		input [DATAWIDTH-1:0] PWDATA,
		input PWRITE,
		input PSELx,
		input PENABLE,
		output [DATAWIDTH-1:0] PRDATA,
		output PREADY,
		
		input reset,
		input clk,
		input channel_format, //0: serial, 1: enhanced
		input optional_pause,
		input config_bit,
		input enable,
		input [3:0] id_4bit,
		input [7:0] id_8bit,
		input [11:0] data_12bit,
		input [15:0] data_16bit,
		input [7:0] data_short,
		

		input clk_rx,
		//output
		output [3:0] data_nibble_rx

	);
	
	//signals apb
	wire [7:0] reg_status;
	wire [7:0] reg_receive;
	wire [7:0] reg_command;
	wire [7:0] reg_temp;
	wire [7:0] reg_pres;
	wire write_enable_f1;
	wire write_enable_f2;

	//signals crc block
	wire [2:0] enable_crc;

	wire [23:0] data_to_crc;

	wire [3:0] crc_serial;
	wire [5:0] crc_enhanced;
	wire [3:0] crc_fast;

	//signals pulse block
	wire ticks;

	//signals to control block
	wire [3:0] data_nibble;
	wire pulse;
	wire sync;
	wire pause;
	wire pulse_done;
	wire idle;

	//signals to data reg block
	wire [1:0] load_bit_f1;
	wire [1:0] load_bit_f2;
	wire done_f1;
	wire done_f2;
	wire [7:0] data_in_f1;
	wire [7:0] data_in_f2;
	wire read_enable_f1;
	wire read_enable_f2;
	wire [15:0] data_f1;
	wire [11:0] data_f2;

	//signals to pulse check block
	/*wire [3:0] data_nibble_rx;
	wire sync_rx;
	wire pause_rx;
	wire channel_error;
	wire data_check_ticks; */

	//signals to crc check
	wire [27:0] data_fast6_to_check_crc;
	wire [19:0] data_fast4_to_check_crc;
	wire [15:0] data_fast3_to_check_crc;
	wire [15:0]  data_short_to_check_crc;
	wire [27:0] data_enhanced_to_check_crc;

	//signals to rx control
	wire done_pre_data_fast6;
	wire done_pre_data_fast4;
	wire done_pre_data_fast3;
	wire done_pre_data_short;
	wire done_pre_data_enhanced; 


	//
	wire valid_data_serial;
	wire valid_data_enhanced;
	wire valid_data_fast;

	wire [7:0] data_serial;
	wire [23:0] data_enhanced;
	wire [23:0] data_fast;

	wire [3:0] id_4bit_decode;
	wire [7:0] id_8bit_decode;
	wire [11:0] data_12bit_decode;
	wire [15:0] data_16bit_decode;
	wire config_bit_decode;
	wire [7:0] data_short_decode;

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
		.reg_status(reg_status),  
		.reg_receive(reg_receive), 
		.reg_command(reg_command), 
		.reg_temp(reg_temp), 
		.reg_pres(reg_pres), 

		//output control fifo tx
		.write_enable_f1(write_enable_f1),
		.write_enable_f2(write_enable_f2)
	);

	async_fifo f1_fifo(
		.write_enable(write_enable_f1), 
		.write_clk(PCLK), 
		.write_reset_n(reg_command[7]),
		.read_enable(read_enable_f1), 
		.read_clk(clk), 
		.read_reset_n(reg_command[6]),
		.write_data(reg_temp),
		.read_data(data_in_f1),
		.write_full(reg_status[7]),
		.read_empty(reg_status[6])
	);

	async_fifo f2_fifo(
		.write_enable(write_enable_f2), 
		.write_clk(PCLK), 
		.write_reset_n(reg_command[7]),
		.read_enable(read_enable_f2), 
		.read_clk(clk), 
		.read_reset_n(reg_command[6]),
		.write_data(reg_pres),
		.read_data(data_in_f2),
		.write_full(reg_status[5]),
		.read_empty(reg_status[4])
	);

	sent_tx_data_reg sent_tx_data_reg(
		//clk and reset
		.clk(clk),
		.reset(reset),

		//signals to control block
		.load_bit_f1(load_bit_f1),
		.load_bit_f2(load_bit_f2),
		.done_f1(done_f1),
		.done_f2(done_f2),
		.data_f1(data_f1),
		.data_f2(data_f2),

		//signals to fifo
		.data_in_f1(data_in_f1),
		.data_in_f2(data_in_f2),
		.read_enable_f1(read_enable_f1),
		.read_enable_f2(read_enable_f2)
	);

	sent_tx_control sent_tx_control(
		//clk and reset
		.clk(clk),
		.reset(reset),

		//normal input
		.channel_format(channel_format), //0: serial(), 1: enhanced
		.optional_pause(optional_pause),
		.config_bit(config_bit),
		.enable(enable),
		.id_4bit(id_4bit),
		.id_8bit(id_8bit),
		.data_12bit(data_12bit),
		.data_16bit(data_16bit),
		.data_short(data_short),

		//signals to crc block
		.crc_serial(crc_serial),
		.crc_enhanced(crc_enhanced),
		.crc_fast(crc_fast),
		.enable_crc(enable_crc),

		.data_to_crc(data_to_crc),
	

		//signals to pulse gen block
		.pulse_done(pulse_done),
		.data_nibble(data_nibble),
		.pulse(pulse),
		.sync(sync),
		.pause(pause),
		.idle(idle),
	
		//signals to data reg block
		.data_f1(data_f1),
		.data_f2(data_f2),
		.load_bit_f2(load_bit_f2),
		.load_bit_f1(load_bit_f1),
		.done_f1(done_f1),
		.done_f2(done_f2)
	);

	sent_tx_pulse_gen sent_tx_pulse_gen(
		//clk and reset
		.ticks(ticks),
		.reset(reset),

		//signals to control
		.data_nibble(data_nibble),
		.pulse(pulse),
		.sync(sync),
		.pause(pause),
		.idle(idle),
		.pulse_done(pulse_done),

		//output
		.data_pulse(data_pulse)
	);
	sent_tx_gen_ticks sent_tx_gen_ticks(
		.clk(clk),
		.reset(reset),
		.ticks(ticks)
	);
	sent_tx_crc_gen sent_tx_crc_gen(
		.reset(reset),
		.crc_serial(crc_serial),
		.crc_enhanced(crc_enhanced),
		.crc_fast(crc_fast),
		.enable_crc(enable_crc),

		.data_to_crc(data_to_crc)
	);

	sent_rx_pulse_check sent_rx_pulse_check(
		.data_pulse(data_pulse),
		.clk_rx(clk_rx),
		.reset(reset),
		.data_nibble_rx(data_nibble_rx),
		.data_fast6_to_check_crc(data_fast6_to_check_crc),
		.data_fast4_to_check_crc(data_fast4_to_check_crc),
		.data_fast3_to_check_crc(data_fast3_to_check_crc),
		.data_short_to_check_crc(data_short_to_check_crc),
		.data_enhanced_to_check_crc(data_enhanced_to_check_crc),
		.done_pre_data_fast6(done_pre_data_fast6),
		.done_pre_data_fast4(done_pre_data_fast4),
		.done_pre_data_fast3(done_pre_data_fast3),
		.done_pre_data_short(done_pre_data_short),
		.done_pre_data_enhanced(done_pre_data_enhanced),

		.id_4bit_decode(id_4bit_decode),
		.config_bit_decode(config_bit_decode),
		.id_8bit_decode(id_8bit_decode),
		.data_12bit_decode(data_12bit_decode),
		.data_16bit_decode(data_16bit_decode),
		.data_short_decode(data_short_decode)
	);

	sent_rx_crc_check sent_rx_crc_check(
		.reset(reset),

		//signals to control block

		.enable_crc_check_fast6(enable_crc_check_fast6),
		.enable_crc_check_fast4(enable_crc_check_fast4),
		.enable_crc_check_fast3(enable_crc_check_fast3),
		.enable_crc_check_serial(enable_crc_check_serial),
		.enable_crc_check_enhanced(enable_crc_check_enhanced),

		.data_fast6_to_check_crc(data_fast6_to_check_crc),
		.data_fast4_to_check_crc(data_fast4_to_check_crc),
		.data_fast3_to_check_crc(data_fast3_to_check_crc),
		.data_short_to_check_crc(data_short_to_check_crc),
		.data_enhanced_to_check_crc(data_enhanced_to_check_crc),

		.valid_data_serial(valid_data_serial),
		.valid_data_enhanced(valid_data_enhanced),
		.valid_data_fast(valid_data_fast),

		.data_serial(data_serial),
		.data_enhanced(data_enhanced),
		.data_fast(data_fast)
	);
	
	sent_rx_control sent_rx_control(
			.clk_rx(clk_rx),
		.reset(reset),

		//
		.done_pre_data_fast6(done_pre_data_fast6),
		.done_pre_data_fast4(done_pre_data_fast4),
		.done_pre_data_fast3(done_pre_data_fast3),
		.done_pre_data_short(done_pre_data_short),
		.done_pre_data_enhanced(done_pre_data_enhanced),


		//signals to crc check
		.enable_crc_check_fast6(enable_crc_check_fast6),
		.enable_crc_check_fast4(enable_crc_check_fast4),
		.enable_crc_check_fast3(enable_crc_check_fast3),
		.enable_crc_check_serial(enable_crc_check_serial),
		.enable_crc_check_enhanced(enable_crc_check_enhanced),

		.valid_data_serial(valid_data_serial),
		.valid_data_enhanced(valid_data_enhanced),
		.valid_data_fast(valid_data_fast),

		.data_serial(data_serial),
		.data_enhanced(data_enhanced),
		.data_fast(data_fast),

		.id_4bit_decode(id_4bit_decode),
		.config_bit_decode(config_bit_decode),
		.id_8bit_decode(id_8bit_decode),
		.data_12bit_decode(data_12bit_decode),
		.data_16bit_decode(data_16bit_decode),
		.data_short_decode(data_short_decode)
	);	

endmodule