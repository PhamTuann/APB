module apb_slave #(localparam ADDRESSWIDTH= 32,
	localparam DATAWIDTH= 8)(
	input PCLK,
	input PRESETn,
	input [ADDRESSWIDTH-1:0]PADDR,
	input [DATAWIDTH-1:0] PWDATA,
	input PWRITE,
	input PSELx,
	input PENABLE,
	output reg [DATAWIDTH-1:0] PRDATA,
	output reg PREADY
	);
	
	reg [DATAWIDTH-1:0] mem[256];

	reg [1:0] state;

	localparam IDLE = 0;
	localparam SETUP = 1;
	localparam WRITE = 2;
	localparam READ = 3;

	assign PREADY = (PENABLE & PSELx & PWRITE) ? 1 : 0;
	always @(posedge PCLK or negedge PRESETn) begin
 		if(!PRESETn) begin
			PRDATA <= 0;
 			state <= IDLE; 
 		end else begin
 			case(state)
				IDLE :  begin
 					PRDATA <= 0;
					if (PSELx & !PENABLE) state <= SETUP;
 					else state <= IDLE;
 				end
 				SETUP : begin
 					if (PSELx & !PENABLE & PWRITE) state <= WRITE;
 					else state <= READ;
 				end
 				WRITE : begin
 					if (PSELx & PENABLE & PWRITE) 
						begin
						mem[PADDR] <= PWDATA; 
						if (!PREADY) state <= WRITE;
 						else if (PSELx) state <= SETUP;
						else state <= IDLE;
					end 
				end
 				READ :  begin
 					if (PSELx & PENABLE & !PWRITE) 
						begin
						mem[PADDR] <= PRDATA; 
						if (!PREADY) state <= READ;
 						else if (PSELx) state <= SETUP;
						else state <= IDLE;
					end 
 				end
 			endcase
 		end
	end
endmodule
