module sent_tx_crc_gen(
	//reset
	input reset,

	//signals to control block
	input [2:0] enable_crc,

	input [23:0] data_to_crc,

	output reg [3:0] crc_serial,
	output reg [5:0] crc_enhanced,
	output reg [3:0] crc_fast
	);

    	reg [15:0] temp_data_serial;
	reg [31:0] temp_six_nibbles;
	reg [23:0] temp_four_nibbles;
	reg [19:0] temp_three_nibbles;
	reg [35:0] temp_data_enhanced;

    	reg [6:0] p;
	reg [6:0] q;
	reg [4:0] poly4 = 5'b11101;
	reg [6:0] poly6 = 7'b1011001;

    	always @(*) begin
		if(reset) begin
			crc_serial = 0;
			crc_fast = 0;
			crc_enhanced = 0;
			temp_data_serial = 0;
			temp_six_nibbles = 0;
			temp_four_nibbles = 0;
			temp_three_nibbles = 0;
			temp_data_enhanced = 0;
		end
		else begin
		//CRC SHORT
		if(enable_crc == 3'b100) begin
        		q = 19;
        		temp_data_serial = {4'b0101, data_to_crc[11:0], 4'b0};

        		while (q > 3) begin

            		if (temp_data_serial[q] == 1'b1) begin
              	  		temp_data_serial[q-0] = temp_data_serial[q-0] ^ 1;
                		temp_data_serial[q-1] = temp_data_serial[q-1] ^ poly4[3];
                		temp_data_serial[q-2] = temp_data_serial[q-2] ^ poly4[2];
                		temp_data_serial[q-3] = temp_data_serial[q-3] ^ poly4[1];
                		temp_data_serial[q-4] = temp_data_serial[q-4] ^ poly4[0];
            		end

            		else begin
                		q = q - 1;
            		end

        	end

        	crc_serial[3] = temp_data_serial[3];
        	crc_serial[2] = temp_data_serial[2];
        	crc_serial[1] = temp_data_serial[1];
        	crc_serial[0] = temp_data_serial[0];
		end
	

		//CRC 6 NIBBLES
		if(enable_crc == 3'b001) begin
        		p = 31;
        		temp_six_nibbles = {4'b0101, data_to_crc, 4'b0};

        		while (p > 3) begin

            		if (temp_six_nibbles[p] == 1'b1) begin
              	  		temp_six_nibbles[p-0] = temp_six_nibbles[p-0] ^ 1;
                		temp_six_nibbles[p-1] = temp_six_nibbles[p-1] ^ poly4[3];
                		temp_six_nibbles[p-2] = temp_six_nibbles[p-2] ^ poly4[2];
                		temp_six_nibbles[p-3] = temp_six_nibbles[p-3] ^ poly4[1];
                		temp_six_nibbles[p-4] = temp_six_nibbles[p-4] ^ poly4[0];
            		end

            		else begin
                		p = p - 1;
            		end

        	end

        	crc_fast[3] = temp_six_nibbles[3];
        	crc_fast[2] = temp_six_nibbles[2];
        	crc_fast[1] = temp_six_nibbles[1];
        	crc_fast[0] = temp_six_nibbles[0];
		end

		//CRC 4 NIBBLES
		if(enable_crc == 3'b010) begin
        		p = 23;
        		temp_four_nibbles = {4'b0101, data_to_crc[15:0], 4'b0};

        		while (p > 3) begin

            		if (temp_four_nibbles[p] == 1'b1) begin
              	  		temp_four_nibbles[p-0] = temp_four_nibbles[p-0] ^ 1;
                		temp_four_nibbles[p-1] = temp_four_nibbles[p-1] ^ poly4[3];
                		temp_four_nibbles[p-2] = temp_four_nibbles[p-2] ^ poly4[2];
                		temp_four_nibbles[p-3] = temp_four_nibbles[p-3] ^ poly4[1];
                		temp_four_nibbles[p-4] = temp_four_nibbles[p-4] ^ poly4[0];
            		end

            		else begin
                		p = p - 1;
            		end

        	end

        	crc_fast[3] = temp_four_nibbles[3];
        	crc_fast[2] = temp_four_nibbles[2];
        	crc_fast[1] = temp_four_nibbles[1];
        	crc_fast[0] = temp_four_nibbles[0];
		end

		//CRC 3 NIBBLES
		if(enable_crc == 3'b011) begin
        		p = 19;
        		temp_three_nibbles = {4'b0101, data_to_crc[11:0], 4'b0};

        		while (p > 3) begin

            		if (temp_three_nibbles[p] == 1'b1) begin
              	  		temp_three_nibbles[p-0] = temp_three_nibbles[p-0] ^ 1;
                		temp_three_nibbles[p-1] = temp_three_nibbles[p-1] ^ poly4[3];
                		temp_three_nibbles[p-2] = temp_three_nibbles[p-2] ^ poly4[2];
                		temp_three_nibbles[p-3] = temp_three_nibbles[p-3] ^ poly4[1];
                		temp_three_nibbles[p-4] = temp_three_nibbles[p-4] ^ poly4[0];
            		end

            		else begin
                		p = p - 1;
            		end

        	end

        	crc_fast[3] = temp_three_nibbles[3];
        	crc_fast[2] = temp_three_nibbles[2];
        	crc_fast[1] = temp_three_nibbles[1];
        	crc_fast[0] = temp_three_nibbles[0];
		end
		
		//CRC ENHANCED
		if(enable_crc == 3'b101) begin
        		q = 35;
        		temp_data_enhanced = {6'b010101, data_to_crc, 6'b0};

        		while (q > 5) begin

            		if (temp_data_serial[p] == 1'b1) begin
              	  		temp_data_enhanced[q-0] = temp_data_enhanced[q-0] ^ 1;
                		temp_data_enhanced[q-1] = temp_data_enhanced[q-1] ^ poly6[5];
                		temp_data_enhanced[q-2] = temp_data_enhanced[q-2] ^ poly6[4];
                		temp_data_enhanced[q-3] = temp_data_enhanced[q-3] ^ poly6[3];
                		temp_data_enhanced[q-4] = temp_data_enhanced[q-4] ^ poly6[2];
				temp_data_enhanced[q-5] = temp_data_enhanced[q-5] ^ poly6[1];
				temp_data_enhanced[q-6] = temp_data_enhanced[q-6] ^ poly6[0];
            		end

            		else begin
                		q = q - 1;
            		end

        	end

		crc_enhanced[5] = temp_data_enhanced[5];
		crc_enhanced[4] = temp_data_enhanced[4];
        	crc_enhanced[3] = temp_data_enhanced[3];
        	crc_enhanced[2] = temp_data_enhanced[2];
        	crc_enhanced[1] = temp_data_enhanced[1];
        	crc_enhanced[0] = temp_data_enhanced[0];
		end


		end
    	end

endmodule

/*
test case
data poly4 CRC4_code
0x2C7 0x13 0xD
0x287 0x13 0xA
0x285 0x15 0xC
0x200 0x18 0x8
*/


