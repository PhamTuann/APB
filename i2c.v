module i2c_master (
	input clk,
	input i2c_reset,
	input [6:0] addr,
	input rw,
	input i2c_enable,
	input [7:0] i2c_data_in,
	output reg [7:0] i2c_data_out,
	output reg i2c_sda,
	output i2c_scl,
	output i2c_ready
	);

	localparam IDLE = 0;
	localparam START = 1;
	localparam ADDRESS = 2;
	localparam READ_ACK = 3;
	localparam WRITE_DATA = 4;
	localparam READ_DATA = 5;
	localparam READ_ACK2 = 6;
	localparam WRITE_ACK = 7;
	localparam STOP = 8;
	localparam DIVIDE_BY = 4;

	reg [7:0] state;
	reg [7:0] saved_addr;
	reg [7:0] saved_data;
	reg [7:0] counter;
	reg [7:0] counter2 = 0;
	reg i2c_scl_enable = 0;
	reg i2c_clk = 1;
	assign i2c_scl = (i2c_scl_enable == 0 ) ? 1 : ~i2c_clk;
	assign i2c_ready = ((!i2c_reset) &&(state == IDLE)) ? 1: 0 ;
	
	always @(posedge clk) begin
		if (counter2 == (DIVIDE_BY/2) - 1) begin
			i2c_clk <= ~i2c_clk;
			counter2 <= 0;
		end
		else counter2 <= counter2 + 1;
	end 

	always @(posedge i2c_clk) begin
		if (i2c_reset) begin
			state <= IDLE;
			i2c_sda <= 1;
		end
		else begin
			case(state)
				IDLE: begin
					if (i2c_enable) begin
						state <= START;
						saved_addr <= {addr, rw};
						saved_data <= i2c_data_in;
						i2c_sda <=1;
					end
					else state <= IDLE;
				end
				START: begin
					i2c_sda <=0;
					counter <= 7;
					state <= ADDRESS;
				end
				ADDRESS: begin
					if (counter == 0) begin 
						state <= READ_ACK;
					end else begin
						counter <= counter - 1;
						i2c_sda <= saved_addr[counter];
					end
				
				end
				READ_ACK: begin
					if (i2c_sda == 0) begin
						counter <= 8;
						if(saved_addr[0] == 0) state <= WRITE_DATA;
						else state <= READ_DATA;
					end else state <= STOP;
				end
				WRITE_DATA: begin
					if (counter != 0) begin
						counter = counter - 1;
						i2c_sda = saved_data[counter];
					end
					else state <= READ_ACK2;
					
				end
				READ_DATA: begin
					i2c_data_out[counter] <= i2c_sda;
					if (counter == 0) state <= WRITE_ACK;
					else counter <= counter - 1;
				end
				READ_ACK2: begin
					if ((i2c_sda == 0) && (i2c_enable == 1)) state <= IDLE;
					else state <= STOP;
				end
				WRITE_ACK: begin
					i2c_sda <=1;
					state <= START;
				end
				STOP: begin
					i2c_sda <=1;
					state <= STOP;
				end
			endcase
		end
	end
	always @(negedge i2c_clk) begin
		if(i2c_reset == 1) begin
			i2c_scl_enable <= 0;
		end else begin
			if ((state == IDLE) || (state == START) || (state == STOP)) begin
				i2c_scl_enable <= 0;
			end else begin
				i2c_scl_enable <= 1;
			end
		end
	
	end
endmodule
