module apb_slave 
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
	output reg [DATAWIDTH-1:0] PRDATA,
	output reg PREADY = 1,

	//register	
	output reg [7:0] reg_command,
	output reg [31:0] reg_transmit,
	input reg [7:0] reg_status,
	input reg [31:0] reg_receive
	);
	//pwdata 32 bit: 7 bit cuoi là data, 7 bit tiep theo la dia chi
	always @(posedge PCLK or negedge PRESETn) begin
 		if(!PRESETn) begin
			PRDATA <= 0;
		end
		else begin
			if (PENABLE & PWRITE & PSELx) begin
				case (PADDR)
					2: reg_command <= PWDATA;
					4: if(!reg_status[7] && reg_status[3]) begin	
						reg_transmit <= PWDATA;
						end
				endcase
			end
			
			if(PENABLE & !PWRITE & PSELx) begin
				case (PADDR)
					3: PRDATA <= reg_status;
					5: PRDATA <= reg_receive;
				endcase
			end
		end
	end
endmodule
