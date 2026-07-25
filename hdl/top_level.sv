`default_nettype none

module top_level(
	input wire clk_100mhz,
//	input wire [15:0] sw,
	input wire [3:0] btn, 
	output logic [15:0] led,
	output logic [2:0] rgb,
	output logic [3:0] an,
	output logic [6:0] seg,

	// SPI 
	output logic copi, 
	input wire cipo, 
	output logic dclk, 
	output logic cs
	);

	// control system reset with a button
	logic sys_rst;
	assign sys_rst = btn[0];

	// count button presses 
	logic [15:0] btn_count;
	assign led = btn_count;

	// downstream variables
	logic [31:0] val_to_display; 
	logic [6:0] ss_c;

	// debounced button 
	logic sig_btn_1;
	debounce btn1_db(
		.clk(clk_100mhz), 
		.rst(sys_rst),
		.in(btn[1]),
		.out(),
		.on_up(sig_btn_1)
	);

	// this signal should go high for one cycle on the debounced button 
	logic btn_pulse;


	/*
	* Edge detector
	* This works by watching the value of sig_btn1_sync
	* Naively at first one may want to check that sig_btn1_sync is not
	* equal to sig_btn_1 this is erronous, we get two edges when sig_btn_1
	* rises and another one when sig_btn1_sync rises, henc our Count is
	* wrong
	* sig_btn1_sync will only be set after sig_btn_1 has been set 
	* this is enough to catch the edge and send the signal onwards
	*/ 
	logic sig_btn1_sync;
	always_ff @(posedge clk_100mhz) begin
		sig_btn1_sync <= sig_btn_1;
		if(sys_rst) begin 
			sig_btn1_sync <= 0;
		end else begin 
			if(sig_btn1_sync) begin 
				btn_pulse <= 1;
			end else begin 
				btn_pulse <= 0; 
			end
		end
	end

	// count presses
	evt_counter msc(
		.clk(clk_100mhz), 
		.rst(sys_rst),
		.evt(btn_pulse), 
		.count(btn_count)
	);

	//assign val_to_display = btn_count;

	seven_segment_controller mssc(
		.clk(clk_100mhz), 
		.rst(sys_rst), 
		.val(val_to_display),
		.cat(ss_c),
		.an(an)
	);


	assign seg = ss_c;

	logic [7:0] red, green, blue; 


	// concat colors into one reg for the seven segment
	assign val_to_display = {red, 4'h0, blue, 4'h0, green};

	/*
	* Add an RGB controller so we can actually see the SPI
	* recieve data and the FPGA use the data we get from the SPI 
	* Controller
	*/
	rgb_controller mrgbc(
		.clk(clk_100mhz),
		.rst(btn[0]), 
		.r_in(red), 
		.g_in(green),
		.b_in(blue), 
		.r_out(rgb[0]), 
		.g_out(rgb[1]),
		.b_out(rgb[2])
		);

	parameter ADC_DATA_WIDTH = 17;
	parameter ADC_DATA_CLK_PERIOD = 50;

	parameter ADC_READ_PERIOD = 100_000;

	// SPI controls needed to send and receive data via SPI
	logic [ADC_DATA_WIDTH-1:0] spi_write_data; // what to write  
	logic [ADC_DATA_WIDTH-1:0] spi_read_data;  // what we read 
	logic spi_trigger; 			   // tell spi to go
	logic spi_read_data_valid;		   // signal that data was good from spi


	/*
	* Instance of the SPI controller 
	* We will use to receive signal signals from the 
	* Analog to Digital Converter 
	*/
	spi_con
	#( .DATA_WIDTH(ADC_DATA_WIDTH),
	   .DATA_CLK_PERIOD(ADC_DATA_CLK_PERIOD)
	 ) adc_spi_con
	 (
		 .clk(clk_100mhz),
		 .rst(sys_rst),
		 .data_in(spi_write_data), 
		 .trigger(spi_trigger),
		 .data_out(spi_read_data), 
		 .data_valid(spi_read_data_valid), // when this blips we have some good data
		 .copi(copi), //MOSI
		 .cipo(cipo), //MISO
		 .dclk(dclk),
		 .cs(cs)
	);

	/*trigger  every ms 
	* We will trigger an SPI transaction every Ms 
	* whever this counter value is at 1, this is  
	* strobe signal 
	*/ 
	logic [31:0] select_count;
	counter select_counter(
		.clk(clk_100mhz), 
		.rst(sys_rst),
		.period(ADC_READ_PERIOD),
		.count(select_count)
	);

	/* adc_count  for cycling channels 
	* three ADC channels to cycle through 
	* inputs for r, g, b
	*/
	logic [1:0] adc_count;


	/*
	* Actuak SPI work 
	* 1. We check if we have read a valid value 
	* 2. If we have read a valid value place it in the color it belongs to 
	* 3. we check if it is time to do a read 
	* 4. if it is time since spi is a write read scheme we send for
	* reading and trigger a read, and cycle the color we are reading
	* 5. Otherwise we dont trigger a read*/
	always_ff @(posedge clk_100mhz) begin
		if(spi_read_data_valid) begin
			case(adc_count)
				0: red  <= spi_read_data[10:3];
				1: green <= spi_read_data[10:3];
				2: blue  <= spi_read_data[10:3];
				default: {red, blue, green} <= 24'h0;
 			endcase
		end
		if(select_count == 'd1) begin
			case(adc_count)
				0: begin
					spi_write_data <= 17'b11000_0000_0000_0000;
				end
				1: begin
					spi_write_data <= 17'b11001_0000_0000_0000;
				end
				2: begin
					spi_write_data <= 17'b11010_0000_0000_0000;
				end 
				default: begin
					spi_write_data <= 0;
				end
			endcase
			spi_trigger <= 1;  // run a reads every ms
			adc_count <= adc_count == 2 ? 0 : adc_count + 1; 
		end else begin 
			spi_trigger <= 0; 
		end 
	end 
endmodule
`default_nettype wire
