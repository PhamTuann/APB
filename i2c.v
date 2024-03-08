module i2c_master(
	// i2c core signal
	input wire clk,
	input wire i2c_reset_n,
	input wire [6:0] addr,
	input wire [7:0] i2c_data_in,
	input wire i2c_enable,
	input wire rw,
	output reg [7:0] i2c_data_out,
	output wire i2c_ready,

	inout i2c_sda,
	inout i2c_scl,
	
	input sda_in,

	//control fifo
	output reg fifo_tx_rd_en,
	output reg fifo_rx_wr_en 
	);

	localparam IDLE = 0;
	localparam START = 1;
	localparam ADDRESS = 2;
	localparam READ_ACK = 3;
	localparam WRITE_DATA = 4;
	localparam WRITE_ACK = 5;
	localparam READ_DATA = 6;
	localparam READ_ACK2 = 7;
	localparam STOP = 8;
	
	localparam DIVIDE_BY = 4;

	reg [7:0] state;
	reg [7:0] saved_addr;
	reg [7:0] counter;
	reg [7:0] counter2 = 0;
	reg write_enable;
	reg sda_out;
	reg i2c_scl_enable = 0;
	reg i2c_clk = 1;
	reg status;

	assign i2c_ready = ((i2c_reset_n == 1) && (state == IDLE)) ? 1 : 0;
	assign i2c_scl = (i2c_scl_enable == 0 ) ? 1 : i2c_clk;
	assign i2c_sda = (write_enable == 1) ? sda_out : sda_in;

	always @(posedge clk) begin
		if(!i2c_reset_n) begin
			i2c_clk <=0;
		end
		else if (counter2 == (DIVIDE_BY/2) - 1) begin
			i2c_clk <= ~i2c_clk;
			counter2 <= 0;
		end
		else counter2 <= counter2 + 1;
	end 
	
	always @(negedge i2c_clk, negedge i2c_reset_n) begin
		if(!i2c_reset_n) begin
			i2c_scl_enable <= 0;
		end else begin
			if ((state == IDLE) || (state == START) || (state == STOP)) begin
				i2c_scl_enable <= 0;
			end else begin
				i2c_scl_enable <= 1;
			end
		end
	
	end

	always @(posedge clk) begin
		if(!i2c_reset_n) begin
			fifo_tx_rd_en <= 0;
		end
		else
		case(state)
			READ_ACK: begin
					
					if (sda_in == 0) begin
						fifo_tx_rd_en <= 1;
						status <= 1;
					end
					if (status == 1) begin
						fifo_tx_rd_en <= 0;
					end
				end
			WRITE_DATA: status <= 0;
		endcase
	end 
	
	always @(posedge i2c_clk, negedge i2c_reset_n) begin
		if(!i2c_reset_n) begin
			state <= IDLE;
			fifo_tx_rd_en <= 0;
			fifo_rx_wr_en <= 0;
		end		
		else begin
			case(state)
				IDLE: begin
					if (i2c_enable) begin
						state <= START;
						saved_addr <= {addr, rw};
					end
					else state <= IDLE;
				end

				START: begin
					counter <= 7;
					state <= ADDRESS;
				end

				ADDRESS: begin
					if (counter == 0) begin 
						state <= READ_ACK;
					end else counter <= counter - 1;
				end

				READ_ACK: begin
					if (sda_in == 0) begin
						counter <= 7;
						if(saved_addr[0] == 0) state <= WRITE_DATA;
						else state <= READ_DATA;
					end else state <= STOP;
				end

				WRITE_DATA: begin
					if(counter == 0) begin
						state <= READ_ACK2;
					end else counter <= counter - 1;
				end
				
				READ_ACK2: begin
					if ((sda_in == 0) && (i2c_enable == 1)) state <= IDLE;
					else state <= STOP;
				end

				READ_DATA: begin
					i2c_data_out[counter] <= sda_in;
					if (counter == 0) begin
						state <= WRITE_ACK;
						fifo_rx_wr_en <= 1;
					end
					else counter <= counter - 1;
				end
				
				WRITE_ACK: begin
					state <= STOP;
					fifo_rx_wr_en <= 0;
				end

				STOP: begin
					state <= IDLE;
				end
			endcase
		end
	end
	
	always @(negedge i2c_clk, negedge i2c_reset_n) begin
		if(!i2c_reset_n) begin
			write_enable <= 1;
			sda_out <= 1;
		end else begin
			case(state)
				
				START: begin
					write_enable <= 1;
					sda_out <= 0;
				end
				
				ADDRESS: begin
					sda_out <= saved_addr[counter];
				end
				
				READ_ACK: begin
					write_enable <= 0;
				end
				
				WRITE_DATA: begin 
					write_enable <= 1;
					sda_out <= i2c_data_in[counter];
				end
				
				WRITE_ACK: begin
					write_enable <= 1;
					sda_out <= 0;
				end
				
				READ_DATA: begin
					write_enable <= 0;				
				end
				
				STOP: begin
					write_enable <= 1;
					sda_out <= 1;
				end
			endcase
		end
	end
	
endmodule
