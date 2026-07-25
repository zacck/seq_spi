`default_nettype none
module pwm(
	input wire clk, 
	input wire rst,
	input wire [7:0] dc_in,
	output logic sig_out);

	logic [31:0] count; 
	logic stb;
	logic [31:0] period = 32'd255;
	logic [7:0] internal_dc;
	counter mc (
		.clk(clk),
		.rst(rst), 
		.period(period),
		.count(count));

	always_ff @(posedge clk) begin
		stb <= 1'b0;
		if (count == 0) stb <= 1'b1;
	end

	always_ff @(posedge clk) begin
		if(stb)
			internal_dc <= dc_in;
	end

	// threshold check to perfom duty_cyle
	always_ff @(posedge clk) begin 
		sig_out <= count < internal_dc;
	end
endmodule 
`default_nettype wire
