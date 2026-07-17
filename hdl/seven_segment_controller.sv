`default_nettype none
module seven_segment_controller #(parameter COUNT_PERIOD = 100000) 
	(
		input wire clk, 
		input wire rst, 
		input wire [31:0] val, // what to display on digits 
		output logic[6:0] cat,  // which segments 
		output logic[3:0] an  // which digits
	);

	logic [3:0] segment_state; 
   	logic [31:0]  segment_counter;
	logic [3:0] sel_values; 
	logic [6:0] led_out;

	bto7s mbto7s(.x(sel_values), .seg(led_out));

	assign cat = led_out; 
	assign an = segment_state; 

	always_ff @(posedge clk) begin 
		if(rst) begin 
			segment_state <= 4'b1110;
			segment_counter <= 32'b0; 
		end else begin 
			if(segment_counter == COUNT_PERIOD) begin 
				segment_counter <= 32'd0;
				segment_state <= {segment_state[2:0], segment_state[3]};
			end else begin 
				segment_counter <= segment_counter + 1; 
			end 
		end 
	end

	/*
	*  We get a 32 bit input of which we only use the lower 16, only
	*  4 leds each with 4 bits.
	*  These 4 bits per a led are hex digits.
	*  What we want to do is for each segment state 1110, 0111, 1011, 1101
	*  we should set sel_values to the 4 corresponding bits in the input
	*  This can be combinational
	*  */

	always_comb begin
		case(segment_state) 
			4'b1110: sel_values = val[3:0];
			4'b1101: sel_values = val[7:4];
			4'b1011: sel_values = val[11:8];
			4'b0111: sel_values = val[15:12];
			default: sel_values = 4'b0000;
		endcase
	end
endmodule
`default_nettype wire
