`default_nettype none

module top_level(
	input wire clk_100mhz,
//	input wire [15:0] sw,
	input wire [3:0] btn, 
	output logic [15:0] led,
	output logic [3:0] an,
	output logic [6:0] seg);

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

	assign val_to_display = btn_count;

	seven_segment_controller mssc(
		.clk(clk_100mhz), 
		.rst(sys_rst), 
		.val(val_to_display),
		.cat(ss_c),
		.an(an)
	);


	assign seg = ss_c;
endmodule
`default_nettype wire
