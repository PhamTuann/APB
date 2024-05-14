module sent_tx_data_reg(
	//clk and reset
	input clk,
	input reset,

	//signals to control block
	input [1:0] load_bit_f1,
	input [1:0] load_bit_f2,

	output reg [15:0] data_f1,
	output reg [11:0] data_f2,
	output reg read_enable_f1,
	output reg read_enable_f2,

	output reg done_f1,	
	output reg done_f2,

	//signals to fifo
	input [7:0] data_in_f1,
	input [7:0] data_in_f2
	);

	reg [4:0] count_enable;
	reg [2:0] count_store;

	reg [7:0] saved_data1;
	reg [7:0] saved_data2;
	reg [5:0] store_data1;
	reg [7:0] saved_data3;
	reg [7:0] saved_data4;
	reg [5:0] store_data2;

	reg [3:0] count_data_f1;
	reg [3:0] count_data_f2;
	
	//CONTROL
	always @(posedge clk or posedge reset) begin
		if(reset) begin
			count_enable <= 0;
			read_enable_f1 <= 0;
			read_enable_f2 <= 0;

			saved_data1 <= 0;
			saved_data2 <= 0;
			store_data1 <= 0;
			saved_data3 <= 0;
			saved_data4 <= 0;
			store_data2 <= 0;

			done_f1 <= 0;
			done_f2 <= 0;

			count_store <= 0;
			
		end
		else begin
			if(load_bit_f1 == 2'b10) begin
				if(count_enable == 6) begin
					read_enable_f1 <= 1;
					count_enable <= 0;
					if(!count_store && count_data_f1 != 3) begin
						saved_data1 <= data_in_f1; 
						count_store <= 1; 
					end else if(!count_store && count_data_f1 == 3) begin
						saved_data1 <= data_in_f1; 
						done_f1 <= 1;
					end else begin 
						saved_data2 <= data_in_f1; 
						count_store <= 0; 
						done_f1 <= 1; 
					end
				end
				else begin count_enable <= count_enable + 1; end
			end

			if(load_bit_f1 == 2'b01) begin
				if(count_enable == 6) begin
					read_enable_f1 <= 1;
					count_enable <= 0;
					if(!count_store && count_data_f1 != 1) begin
						saved_data1 <= data_in_f1; 
						count_store <= 1; 
					end else if(!count_store && count_data_f1 == 1) begin
						saved_data1 <= data_in_f1; 
						done_f1 <= 1;
					end else begin 
						saved_data2 <= data_in_f1; 
						count_store <= 0; 
						done_f1 <= 1; 
					end
				end
				else begin count_enable <= count_enable + 1; end
			end

			if(load_bit_f1 == 2'b11) begin
				if(count_enable == 6) begin
					read_enable_f1 <= 1;
					count_enable <= 0;
					if(!count_store) begin
						saved_data1 <= data_in_f1; 
						count_store <= 1; 
					end else begin 
						saved_data2 <= data_in_f1; 
						count_store <= 0; 
						done_f2 <= 1; 
					end
				end
				else begin count_enable <= count_enable + 1; end
			end

			if(load_bit_f1 == 2'b11) begin
				if(count_enable == 6) begin
					read_enable_f2 <= 1;
					count_enable <= 0;
					if(!count_store && count_data_f2 != 1) begin
						saved_data3 <= data_in_f2; 
						count_store <= 1; 
					end else if(!count_store && count_data_f2 == 1) begin
						saved_data3 <= data_in_f2; 
						done_f2 <= 1;
					end else begin 
						saved_data4 <= data_in_f2; 
						count_store <= 0; 
						done_f2 <= 1; 
					end
				end
				else begin count_enable <= count_enable + 1; end
			end	

			if(load_bit_f1 == 2'b10) begin
				if(count_enable == 6) begin
					read_enable_f2 <= 1;
					count_enable <= 0;
					if(!count_store && count_data_f2 != 3) begin
						saved_data3 <= data_in_f2; 
						count_store <= 1; 
					end else if(!count_store && count_data_f2 == 3) begin
						saved_data3 <= data_in_f2; 
						done_f2 <= 1;
					end else begin 
						saved_data4 <= data_in_f2; 
						count_store <= 0; 
						done_f2 <= 1; 
					end
				end
				else begin count_enable <= count_enable + 1; end
			end	

			if(load_bit_f1 == 2'b01) begin
				if(count_enable == 6) begin
					read_enable_f2 <= 1;
					count_enable <= 0;
					saved_data3 <= data_in_f2; 
				end
				else begin count_enable <= count_enable + 1; end
			end	

			if(done_f1) done_f1 <= 0;
			if(read_enable_f1) read_enable_f1 <= 0;
			if(done_f2) done_f2 <= 0;
			if(read_enable_f2) read_enable_f2 <= 0;
		end
	
	end

	//DATA
	always @(negedge clk or posedge reset) begin
		if(reset) begin
			count_data_f1 <= 0;
			count_data_f2 <= 0;
			data_f1 <= 0;
			data_f2 <= 0;
		end
		else begin
			//data fast channel 1
			if(done_f1) begin 
				if(load_bit_f1 == 2'b10) begin
					if(count_data_f1 == 0)begin data_f1 <= {saved_data1, saved_data2[7:2]}; store_data1 <= saved_data2[1:0]; count_data_f1 <= 1; end
					if(count_data_f1 == 1)begin data_f1 <= {store_data1[1:0],saved_data1, saved_data2[7:4]}; store_data1 <= saved_data2[3:0]; count_data_f1 <= 2; end
					if(count_data_f1 == 2)begin data_f1 <= {store_data1[3:0],saved_data1,saved_data2[7:6]}; store_data1 <= saved_data2[5:0]; count_data_f1 <= 3; end
					if(count_data_f1 == 3)begin data_f1 <= {store_data1,saved_data1}; count_data_f1 <= 0; end
				end

				if(load_bit_f1 == 2'b11) begin data_f1 <= {saved_data1, saved_data2}; end
				
				if(load_bit_f1 == 2'b01) begin
					if(count_data_f1 == 0)begin data_f1 <= {saved_data1, saved_data2[7:4]}; store_data1 <= saved_data2[3:0]; count_data_f1 <= 1; end
					if(count_data_f1 == 1)begin data_f1 <= {store_data1[3:0], saved_data1}; count_data_f1 <= 0; end
				end
			end
	
			//data fast channel 2
			if(done_f2) begin 
				if(load_bit_f2 == 2'b01) begin data_f2 <= saved_data3; end

				if(load_bit_f2 == 2'b10) begin 
					if(count_data_f2 == 0) begin data_f2 <= {saved_data3, saved_data4[7:6]}; store_data2 <= saved_data4[5:0]; count_data_f2 <= 1; end
					if(count_data_f2 == 1) begin data_f2 <= {store_data2, saved_data3[7:4]}; store_data2 <= saved_data4[3:0]; count_data_f2 <= 2; end
					if(count_data_f2 == 2) begin data_f2 <= {store_data2[3:0], saved_data3[7:2]}; store_data2 <= saved_data4[1:0]; count_data_f2 <= 3; end
					if(count_data_f2 == 3) begin data_f2 <= {store_data2[1:0], saved_data3}; count_data_f2 <= 0; end
				end
				if(load_bit_f2 == 2'b11) begin
					if(count_data_f2 == 0)begin data_f2 <= {saved_data3, saved_data4[7:4]}; store_data2 <= saved_data4[3:0]; count_data_f2 <= 1; end
					if(count_data_f2 == 1)begin data_f2 <= {store_data2[3:0], saved_data3}; count_data_f2 <= 0; end
				end
			end
		end
	end
endmodule
