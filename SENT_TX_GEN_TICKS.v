module sent_tx_gen_ticks(
	input clk,
	input reset,
	output reg ticks
	);

	localparam divide = 4;
	reg [7:0] counter = 0;

	always @(posedge clk) begin
		if(reset) begin
			ticks <= 0;
			counter <= 0;
		end
		else begin
			if (counter == (divide/2) - 1) begin
				ticks <= ~ticks;
				counter <= 0;
			end
			else counter <= counter + 1;
		end
	end
endmodule
