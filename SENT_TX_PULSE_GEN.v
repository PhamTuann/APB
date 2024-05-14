module sent_tx_pulse_gen(
	//clk and reset
	input ticks,
	input reset,

	//signals to control
	input [3:0] data_nibble,
	input pulse,
	input sync,
	input pause,
	input idle,
	output reg pulse_done,

	//output
	output reg data_pulse
	);

	reg [3:0] count_zero;
	reg [7:0] count_data;	
	reg [8:0] count_ticks;

	reg [3:0] count_zero_idle;

	always @(posedge ticks or posedge reset) begin
		if(reset) begin
			data_pulse <= 1;
			pulse_done <= 0;
			count_zero <= 0;
			count_data <= 0;
			count_ticks <= 0;
			count_zero_idle <= 0;
		end
		else begin
			if(sync) begin
				count_zero_idle <= 0;
				if(count_zero == 5) begin
					data_pulse <= 1;
					if(count_data == 51) begin
						data_pulse <= 0;
						count_data <= 0;
						count_zero <= 0;
						pulse_done <= 1;
						count_ticks <= count_ticks + 56;
					end
					else begin
						count_data <= count_data + 1;
					end
				end 
				else begin
					count_zero <= count_zero + 1;
					data_pulse <= 0;
				end
			end

			if(pulse) begin
				if(count_zero == 5) begin
					data_pulse <= 1;
					if(count_data == 7 + data_nibble) begin
						data_pulse <= 0;
						count_data <= 0;
						count_zero <= 0;
						pulse_done <= 1;
						count_ticks <= count_ticks + 12 + data_nibble;
					end
					else begin
						count_data <= count_data + 1;
					end
				end 
				else begin
					count_zero <= count_zero + 1;
					data_pulse <= 0;
				end
			end
			
			if(pause) begin
				if(count_zero == 5) begin
					data_pulse <= 1;
					if(count_data == 250 - count_ticks ) begin
						data_pulse <= 0;
						count_data <= 0;
						count_zero <= 0;
						pulse_done <= 1;
						count_ticks <= 0;
					end
					else begin
						count_data <= count_data + 1;
					end
				end 
				else begin
					count_zero <= count_zero + 1;
					data_pulse <= 0;
				end
			end
			if(idle) begin
				if(count_zero_idle == 5) begin
					data_pulse <= 1;
				end 
				else begin
					count_zero_idle <= count_zero_idle + 1;
					data_pulse <= 0;
				end
			end
		end
	end	
	
	always @(negedge ticks or posedge reset) begin
		if(reset) begin

		end
		else begin
			if(pulse_done) pulse_done <= 0;
		end
	end
endmodule
