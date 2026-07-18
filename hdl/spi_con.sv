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

	logic [31:0]internal_count;

	always_ff @(posedge clk) begin
		if(trigger) begin
			internal_count  <= DATA_CLK_PERIOD - 1;
		end else begin 
			if(internal_count > 0)
				internal_count <= internal_count - 1;
		end 
	end 
endmodule

