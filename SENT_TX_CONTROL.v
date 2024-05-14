module sent_tx_control(
	//clk and reset
	input clk,
	input reset,

	//normal input
	input channel_format, //0: serial, 1: enhanced
	input optional_pause,
	input config_bit,
	input enable,
	input [3:0] id_4bit,
	input [7:0] id_8bit,
	input [11:0] data_12bit,
	input [15:0] data_16bit,
	input [7:0] data_short,
	
	//signals to crc block
	input [3:0] crc_serial,
	input [5:0] crc_enhanced,
	input [3:0] crc_fast,
	
	output reg [2:0] enable_crc,
	output reg [23:0] data_to_crc,

	//signals to pulse gen block
	input pulse_done,
	output reg [3:0] data_nibble,
	output reg pulse,
	output reg sync,
	output reg pause,
	output reg idle,
	
	//signals to data reg block
	input [15:0] data_f1,
	input [11:0] data_f2,
	output reg [1:0] load_bit_f1,
	output reg [1:0] load_bit_f2,

	input done_f1,	
	input done_f2
	);

	//frame format of fast channels
	localparam TWO_FAST_CHANNELS_12_12 = 0;
	localparam ONE_FAST_CHANNELS_12 = 1;
	localparam HIGH_SPEED_ONE_FAST_CHANNEL_12 = 2;
	localparam SECURE_SENSOR = 3;
	localparam SINGLE_SENSOR_12_0 = 4;
	localparam TWO_FAST_CHANNELS_14_10 = 5;
	localparam TWO_FAST_CHANNELS_16_8 = 6;

	//state FSMs
	localparam IDLE = 0;
	localparam SYNC = 1;
	localparam STATUS = 2;
	localparam DATA = 3;
	localparam CRC = 4;
	localparam PAUSE = 5;

	reg [2:0] frame_format;
	reg [2:0] state;
	reg [23:0] six_nibbles;
	reg [5:0] count_frame;
	reg sig_prev;
	reg [2:0] count_nibble;
	
	reg [2:0] count_load;

	reg [15:0] saved_short_data;
	reg [17:0] saved_enhanced_bit3;
	reg [17:0] saved_enhanced_bit2;

	reg crc_done;  
	
	//HANDLE FRAME FORMAT
	always @(data_short) begin
		if(data_short == 12'h006 || data_short == 12'h007 || data_short == 12'h008 || data_short == 12'h009
		|| data_short == 12'h00A || data_short == 12'h00C) begin
			frame_format = 0;
		end
		if(data_short == 12'h001) begin
			frame_format = 5;
		end
		if(data_short == 12'h003) begin
			frame_format = 2;
		end
	end
	
	//PREPARE DATA ENHANCED TO GEN CRC
	always @(channel_format or id_8bit or id_4bit or data_12bit or data_16bit) begin
		if(!channel_format) begin
			data_to_crc = {id_4bit, data_short};
		end
		else data_to_crc = 0;

		if(channel_format && !config_bit) begin 
			data_to_crc = {data_12bit[11], 1'b0, data_12bit[10], config_bit
						,data_12bit[9], id_8bit[7], data_12bit[8], id_8bit[6]
						,data_12bit[7], id_8bit[5] , data_12bit[6], id_8bit[4]
						,data_12bit[5], 1'b0, data_12bit[4], id_8bit[3]
						,data_12bit[3], id_8bit[2], data_12bit[2], id_8bit[1]
						,data_12bit[1], id_8bit[0], data_12bit[0], 1'b0 };
		end
		else begin 
			data_to_crc = {data_16bit[11], 1'b0, data_16bit[10], config_bit
						,data_16bit[9], id_4bit[3], data_16bit[8], id_4bit[2]
						,data_16bit[7], id_4bit[1], data_16bit[6], id_4bit[0]
						,data_16bit[5], 1'b0, data_16bit[4], data_16bit[15]
						,data_16bit[3], data_16bit[14], data_16bit[2], data_16bit[13]
						,data_16bit[1], data_16bit[12], data_16bit[0], data_16bit[11] };	
		end
		
	end

	//SAVED D
	always @(crc_done or id_8bit or id_4bit or data_12bit or data_16bit or data_short or crc_serial) begin
		if(crc_done) begin 
			//PRE SAVED DATA
			if(!channel_format) saved_short_data = {id_4bit, data_short, crc_serial};
			else if(channel_format && !config_bit) begin
				saved_enhanced_bit3 = {7'b1111110, config_bit, id_8bit[7:4],1'b0,id_8bit[3:0], 1'b0};
				saved_enhanced_bit2 = {crc_enhanced, data_12bit};
			end
			else begin
				saved_enhanced_bit3 = {7'b1111110, config_bit, id_4bit,1'b0,data_16bit[15:12], 1'b0};
				saved_enhanced_bit2 = {crc_enhanced, data_16bit[11:0]};
			end
		end
	end

	//FSM
	always @(posedge clk or posedge reset) begin
		if(reset) begin
			data_nibble <= 0;
			state <= IDLE;
			sync <= 0;
			pause <= 0;
			pulse <= 0;
			idle <= 0;
			count_frame <= 0;
			saved_short_data <= 0;
			saved_enhanced_bit3 <= 0;
			saved_enhanced_bit2 <= 0;
			six_nibbles <= 0;

			enable_crc <= 0;
			data_to_crc <= 0;

			load_bit_f1 <= 0;
			load_bit_f2 <= 0;


			count_load <= 0;
		end
		else begin
			sig_prev <= pulse_done;
			case(state) 
				IDLE: begin
					//CONTROL PULSE GEN
					pulse <= 0;

					//CHANGE STATE					
					if(enable) begin
						state <= SYNC;
						count_frame <= 0;
						idle <= 0;

						//ENABLE CRC SHORT && ENHANCED
						if(!channel_format) begin enable_crc <= 3'b100; crc_done <= 1; end
						else begin enable_crc <= 3'b101; crc_done <= 1; end

					end
					
					
					
				end
				SYNC: begin
					//CHANGE STATE
					sync <= 1;
					if((pulse_done == 0) && (sig_prev==1)) begin
    						state <= STATUS;
  					end

					//PRE DATA FAST && ENABLE CRC DATA FAST
					case(frame_format) 
						TWO_FAST_CHANNELS_12_12: begin 
							if(count_load == 0) begin load_bit_f1 <= 2'b01; count_load <= 1; end 
							if(done_f1) begin load_bit_f2 <= 2'b11; load_bit_f1 <= 2'b00; end
							if(done_f2) begin 	
								enable_crc <= 3'b001; 
								load_bit_f2 <= 2'b00; 
								data_to_crc <= {data_f1[11:0], data_f2[3:0], data_f2[7:4], data_f2[11:8]};
							end
						end
						
						ONE_FAST_CHANNELS_12: begin 
							if(count_load == 0) begin load_bit_f1 <= 2'b01; count_load <= 1; end 
							if(done_f1) begin 
								enable_crc <= 3'b011; 
								load_bit_f1 <= 2'b00; 
								data_to_crc <= {data_f1[11:0]};
							end
						end

						HIGH_SPEED_ONE_FAST_CHANNEL_12: begin 
							if(count_load == 0) begin load_bit_f1 <= 2'b01; count_load <= 1; end 
							if(done_f1) begin 
								enable_crc <= 3'b010; 
								load_bit_f1 <= 2'b00; 
								data_to_crc <= {1'b0,data_f1[11:9],1'b0,data_f1[8:6],1'b0,data_f1[5:3],1'b0,data_f1[2:0]};
							end 
						end

						SECURE_SENSOR: begin 
							if(count_load == 0) begin load_bit_f1 <= 2'b01; count_load <= 1; end 
							if(done_f1) begin
								enable_crc <= 3'b001; 
								load_bit_f1 <= 2'b00; 
								data_to_crc <= {data_f1[11:0],!data_f1[11:9]};
							end
						end
						
						SINGLE_SENSOR_12_0: begin 
							if(count_load == 0) begin load_bit_f1 <= 2'b01; count_load <= 1; end 
							if(done_f1) begin 
								enable_crc <= 3'b001; 
								load_bit_f1 <= 2'b00; 
								data_to_crc = {data_f1[11:0],12'b0};
							end
						end
						TWO_FAST_CHANNELS_14_10: begin 
							if(count_load == 0) begin load_bit_f1 <= 2'b10; count_load <= 1; end 
							if(done_f1) begin load_bit_f1 <= 2'b10; load_bit_f2 <= 2'b10; end
							if(done_f2) begin 
								enable_crc <= 3'b001; 
								load_bit_f2 <= 2'b00; 
								data_to_crc = {data_f1[13:0],data_f2[1:0],data_f2[5:2],data_f2[9:6]};
							end
						end

						TWO_FAST_CHANNELS_16_8: begin 
							if(count_load == 0) begin load_bit_f1 <= 2'b11; count_load <= 1; end 
							if(done_f1) begin load_bit_f1 <= 2'b00; load_bit_f2 <= 2'b01; end
							if(done_f2) begin 
								enable_crc <= 3'b001; 
								load_bit_f2 <= 2'b01; 
								data_to_crc = {data_f1,data_f2[3:0],data_f2[7:4]};
							end
						end	
					endcase
			
				end
				STATUS: begin
					count_load <= 0;
					//CONTROL PULSE GEN
					sync <= 0;
					pulse <= 1;

					//TURN OFF ENABLE CRC 
					if(enable_crc != 0) enable_crc <= 3'b000; 

					//CHANGE STATE
					if(!channel_format) begin
						data_nibble[2] <= saved_short_data[15];
						if(count_frame ==0) begin
							data_nibble[3] <= 1;
						end
						else data_nibble[3] <= 0;

						if((pulse_done == 0) && (sig_prev==1)) begin
    							state <= DATA;
							saved_short_data <= {saved_short_data[14:0], 1'b0};
  						end
					end
					else begin
						data_nibble[2] <= saved_enhanced_bit2[17];
						data_nibble[3] <= saved_enhanced_bit3[17];

						if((pulse_done == 0) && (sig_prev==1)) begin
    							state <= DATA;
							saved_enhanced_bit2 <= {saved_enhanced_bit2[16:0], 1'b0};
							saved_enhanced_bit3 <= {saved_enhanced_bit3[16:0], 1'b0};
  						end
					end
				end
				DATA: begin
					//CONTROL PULSE GEN
					pulse <= 1;
					
					//CHANGE STATE
					if( (frame_format == TWO_FAST_CHANNELS_12_12) || (frame_format == SECURE_SENSOR)|| (frame_format == SINGLE_SENSOR_12_0)||
					(frame_format == TWO_FAST_CHANNELS_14_10) || (frame_format == TWO_FAST_CHANNELS_16_8) ) begin
						data_nibble <= data_to_crc[23:20];
						if((pulse_done == 0) && (sig_prev==1)) begin
    							count_nibble <= count_nibble + 1;
							data_to_crc <= {data_to_crc[19:0], 4'b0000};
  						end
					end
					else if(frame_format == ONE_FAST_CHANNELS_12) begin 
						data_nibble <= data_to_crc[11:8];
						if((pulse_done == 0) && (sig_prev==1)) begin
    							count_nibble <= count_nibble + 1;
							data_to_crc <= {data_to_crc[7:0], 4'b0000};
  						end
					end
					else if(frame_format == HIGH_SPEED_ONE_FAST_CHANNEL_12) begin 
						data_nibble <= data_to_crc[15:12];
						if((pulse_done == 0) && (sig_prev==1)) begin
    							count_nibble <= count_nibble + 1;
							data_to_crc <= {data_to_crc[11:0], 4'b0000};
  						end
					end
				end
				
				CRC: begin
					//CONTROL PULSE GEN
					pulse <= 1;

					//CHANGE STATE
					data_nibble <= crc_fast;
					if((pulse_done == 0) && (sig_prev==1)) begin
    						pulse <= 0;
						if(optional_pause) state <= PAUSE;
						else begin
							if(!channel_format && count_frame != 15) begin
								state <= SYNC;
								count_frame <= count_frame + 1;
							end
							else if(channel_format && count_frame != 17) begin
 								state <= SYNC;
								count_frame <= count_frame + 1;
							end
							else begin state <= IDLE; idle <= 1; end
						end		
					end
				end
				PAUSE: begin
					//CONTROL PULSE GEN
					pause <= 1;

					//CHANGE STATE
					if((pulse_done == 0) && (sig_prev==1)) begin
    						pause <= 0;
						if(!channel_format && count_frame != 15) begin
								state <= SYNC;
								count_frame <= count_frame + 1;
							end
							else if(channel_format && count_frame != 17) begin
								 state <= SYNC;
								count_frame <= count_frame + 1;
							end
							else begin state <= IDLE; idle <= 1; end
					end

				end

			endcase
		end
	end
	
	
	always @(negedge clk or posedge reset) begin	
		if(reset) begin
			count_nibble <= 0;
		end
		else begin
			if(crc_done) crc_done <= 0;
			if(state == DATA) begin
				if( (frame_format == TWO_FAST_CHANNELS_12_12) || (frame_format == SECURE_SENSOR)|| (frame_format == SINGLE_SENSOR_12_0)||
					(frame_format == TWO_FAST_CHANNELS_14_10) || (frame_format == TWO_FAST_CHANNELS_16_8) ) begin
					if(count_nibble == 6) begin
						count_nibble <= 0;
						state <= CRC;
					end
					else state <= DATA;
				end
				else if(frame_format == ONE_FAST_CHANNELS_12) begin 
					if(count_nibble == 3) begin
						count_nibble <= 0;
						state <= CRC;
					end
					else state <= DATA;
				end
				else if(frame_format == HIGH_SPEED_ONE_FAST_CHANNEL_12) begin 
					if(count_nibble == 4) begin
						count_nibble <= 0;
						state <= CRC;
					end
					else state <= DATA;
				end
			end
		end
	end
	
endmodule
