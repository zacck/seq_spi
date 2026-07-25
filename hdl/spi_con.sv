module spi_con 
	#(parameter DATA_WIDTH = 8, 
	  parameter DATA_CLK_PERIOD = 100
	)
	(	
		// FPGA signals
		input wire clk, // system clk
		input wire rst, // reset signal 
		input wire [DATA_WIDTH-1:0] data_in, // data to send 
		input wire trigger, // go now 
		output logic [DATA_WIDTH-1:0] data_out, //rxed data
		output logic data_valid, // blip when data out is good 
		
		// Out of FPGA signals 
		output logic copi, // controller out peripheral in -> used to be MOSI
		input wire cipo, // controller in peripheral out -> used to be MISO 
		output logic dclk, // data clock 
		output logic cs // Chip Select
	);

	logic [31:0]bit_counter;
	logic [31:0]clk_period_count;
	logic [DATA_WIDTH-1: 0] copi_buffer;
	logic [DATA_WIDTH-1: 0] cipo_buffer;

	always_ff @(posedge clk) begin 
		if(rst) begin 
			data_out <= 0; 
			data_valid <= 0; 
			copi <= 0; 
			dclk <= 0; 
			cs <= 1;
		end
		
		// run dclk at 50% duty
		if(trigger) begin 
			cs <= 0;
			bit_counter <= DATA_WIDTH - 1;
			copi_buffer <= data_in;	
		end else begin
			if(cs == 0) begin
				if (clk_period_count == 0) begin
					clk_period_count <= DATA_CLK_PERIOD -1;
					dclk <= 0;
				end else if(clk_period_count <= (DATA_CLK_PERIOD >> 1)) begin
					clk_period_count <= clk_period_count - 1;
					dclk <= 1;
				end else begin
					clk_period_count <= clk_period_count - 1;
					dclk <= 0;
				end

				//set copi to MSB of copi buffer 
				//shift copi_buffer by 1 to the left
				// reduce bit counter 
				// when done with bits 
				// raise cs 
				// when dclk goes high 
				// read cipo to cipo_buffer
				if (bit_counter == 0) begin 
					cs <= 1;
					data_valid <= 1; 
					data_out <= cipo_buffer;
				end else if((dclk == 0) && (clk_period_count == DATA_CLK_PERIOD - 1)) begin 
					copi <= copi_buffer[DATA_WIDTH-1];
					copi_buffer <= {copi_buffer[DATA_WIDTH-2:0], 1'b0};
					bit_counter <= bit_counter - 1;
				end else if((dclk == 1) && (clk_period_count == ((DATA_CLK_PERIOD >> 1) - 1))) begin 
					cipo_buffer <= {cipo_buffer[DATA_WIDTH-2:0], cipo};
				end
			end else 
				data_valid <= 0;
		end 
	end
endmodule

