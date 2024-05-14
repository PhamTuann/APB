module sent_rx_pulse_check (
	input reset,
	input data_pulse,
	input clk_rx,
	output reg [3:0] data_nibble_rx,

	output reg [27:0] data_fast6_to_check_crc,
	output reg [19:0] data_fast4_to_check_crc,
	output reg [15:0] data_fast3_to_check_crc,
	output reg [15:0] data_short_to_check_crc,
	output reg [27:0] data_enhanced_to_check_crc,

	output reg done_pre_data_fast6,
	output reg done_pre_data_fast4,
	output reg done_pre_data_fast3,
	output reg done_pre_data_short,
	output reg done_pre_data_enhanced,

	output reg [3:0] id_4bit_decode,
	output reg [7:0] id_8bit_decode,
	output reg [7:0] data_short_decode,
	output reg [11:0] data_12bit_decode,
	output reg [15:0] data_16bit_decode,
	output reg config_bit_decode
	);
	

	localparam COUNT_TICKS = 1;
	localparam DONE = 2;

	localparam IDLE = 0;
	localparam SYNC = 1;
	localparam STATUS = 2;
	localparam DATA = 3;
	localparam CRC = 4;
	localparam PAUSE = 5;	

	reg a;
	reg tick = 0;
	reg start;
	reg [10:0] b;
	reg d;
	reg [10:0] counter2;
	reg [1:0] count;
	reg [2:0] state;
	reg [2:0] state_a;
	reg [6:0] count_data;
	reg [5:0] count_frame;
	reg [6:0] count_ticks;

	reg status;
	reg [3:0] status_nb;

	reg [17:0] data1;
	reg [17:0] data2;
	reg [27:0] data3;
	reg done;
	reg done_data;
	reg done_state;
	reg [2:0] count_nibbles;
	
	reg serial;
	reg enhanced;
	reg first_frame;
	//count tick
	always @(posedge clk_rx or posedge reset) begin
		if(reset) begin
			b <= 0;
			start <= 0;	
			count <= 0;
			state <= IDLE;
			counter2 = 0;
			data_nibble_rx <= 0;
			serial <= 0;
			enhanced <= 0;
			config_bit_decode <= 0;
		end
		else begin
			a <= data_pulse;
			case(state)
				IDLE: begin
					if((data_pulse==0) && (a==1)) begin
						state <= COUNT_TICKS;
					end
				end
				COUNT_TICKS: begin
					if((data_pulse==0) && (a==1)) begin
						state <= DONE;
						b <= (counter2+1)/56/2;	
					end
					else counter2 <= counter2 + 1;
				end
				DONE: begin
					counter2 <= 0;
				end
			endcase
		end
	end

	//tick -> tick clk
	always @(posedge clk_rx) begin
		if (count == b-1) begin
			tick <= ~tick;
			count <= 0;
		end
		else count <= count + 1;
	end
	

	//FSM
	always @(posedge tick or posedge reset) begin
		if(reset) begin
			state_a <= STATUS;
			count_data <= 0;
			d <=0;
			count_frame <= 0;
			status <= 0;
			status_nb <= 0;
			count_ticks <= 0;
			data1 <= 0;
			data2 <= 0;
			done <= 0;
			done_data <= 0;
			data3 <= 0;
			count_nibbles <= 0;
			done_state <= 0;
			data_fast6_to_check_crc <= 0;
			data_fast4_to_check_crc <= 0;
			data_fast3_to_check_crc <= 0;
			data_short_to_check_crc <= 0;
			data_enhanced_to_check_crc <= 0;

			done_pre_data_fast6 <= 0;
			done_pre_data_fast4 <= 0;
			done_pre_data_fast3 <= 0;
			done_pre_data_short <= 0;
			done_pre_data_enhanced <= 0;

			id_4bit_decode <= 0;
			config_bit_decode <= 0;
			id_8bit_decode <= 0;
			data_12bit_decode <= 0;
			data_16bit_decode <= 0;
			data_short_decode <= 0;
			
			first_frame <= 0;
		end
		else begin
			d <= data_pulse;

			case(state_a)
				IDLE: begin
					count_frame <= 0;
					data1 <= 0;
					data2 <= 0;
					if ((data_pulse==0) && (d==1)) begin
						state_a <= SYNC;
					end
					else state_a <= IDLE;
				end
				SYNC: begin
					if ((data_pulse==0) && (d==1)) begin
						status <= 1;
						state_a <= STATUS;
					end
					else state_a <= SYNC;
				end
		
				STATUS: begin
					if ((data_pulse==0) && (d==1)) begin
						if(!first_frame) status_nb <= count_data - 13;
						else status_nb <= count_data - 12;
						count_data <= 0;
						state_a <= DATA;
						status <= 0;
						done <= 1;
					end
					else count_data <= count_data + 1;
				end

				DATA: begin
					first_frame <= 1;
					if(count_frame == 1 && status_nb[3]) enhanced <= 1;
					else if(count_frame == 1 && !status_nb[3]) serial <= 1;
					
					if(count_frame == 7 && enhanced) config_bit_decode <= status_nb[3];

					count_ticks <= count_ticks+1;
					if(count_ticks > 27) begin
						data3 <= 0;
						count_ticks <= 0;
						count_data <= 0;
						if(count_nibbles == 7) begin count_nibbles <= 0; data_fast6_to_check_crc <= data3; done_pre_data_fast6 <= 1; end
						else if(count_nibbles == 5) begin count_nibbles <= 0; data_fast4_to_check_crc <= data3; end
						else if(count_nibbles == 4) begin count_nibbles <= 0; data_fast3_to_check_crc <= data3; end

						if(serial && count_frame == 15) begin 
							done_pre_data_short <= 1; 
							state_a <= IDLE; 
							state <= IDLE; 
							serial <= 0; 
						end
						else if(enhanced && count_frame == 17) begin 
							done_pre_data_enhanced<= 1; 
							state_a <= IDLE; 
							state <= IDLE; 
							enhanced <= 0; 
						end
						else begin 
							state_a <= SYNC; 
							count_frame <= count_frame + 1; 
						end
					end
					else begin
						if ((data_pulse==0) && (d==1)) begin
							data_nibble_rx <= count_data - 12;
							count_data <= 0;
							state_a <= DATA;
							count_ticks <= 0;
							done_data <= 1;
							count_nibbles <= count_nibbles + 1;
						end
						else begin 
							count_data <= count_data + 1; 
						end
					end
				end
			endcase
		end
	end

	always @(posedge clk_rx or reset) begin
		if(reset) begin
			data_short_decode <= 0;
		end
		else begin
			if(done) begin
				data1 <= {data1,status_nb[3]};
				data2 <= {data2,status_nb[2]};
				done <= 0;
			end

			if(done_data) begin
				data3 <= {data3,data_nibble_rx};
				done_data <= 0;
			end

			if(done_pre_data_short) begin
				data_short_to_check_crc <= data2[15:0];
				id_4bit_decode <= data2[15:12];
				data_short_decode <= data2[11:4];
				done_pre_data_short <= 0;
			end

			if(done_pre_data_enhanced) begin
				data_enhanced_to_check_crc <= {data2[11],data1[11],
							data2[10],data1[10],
							data2[9],data1[9],
							data2[8],data1[8],
							data2[7],data1[7],
							data2[6],data1[6],
							data2[5],data1[5],
							data2[4],data1[4],
							data2[3],data1[3],
							data2[2],data1[2],
							data2[1],data1[1],
							data2[0],data1[0],
							data2[17],data2[16],
							data2[15],data2[14],
							data2[13],data2[12]
							};

				done_pre_data_enhanced <= 0;

				if(config_bit_decode) begin
					id_4bit_decode <= data1[9:6];
					data_16bit_decode <= {data1[4:1], data2[11:0]};
				end
				else begin
					id_8bit_decode <= {data1[9:6], data1[4:1]};
					data_12bit_decode <= data2[11:0];
				end
			end
		end
	end

	always @(negedge clk_rx or reset) begin
		if(done_pre_data_fast6) done_pre_data_fast6 <= 0;

	end

endmodule