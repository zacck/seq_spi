`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: Gaiaochos
// Engineer: Zacck Osiemo
// 
// Create Date: 06/09/2026 08:07:39 AM EK770 DXB - CPT
// Design Name: 
// Module Name: debounce
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module debounce(
    input wire logic clk,
    input wire logic rst,
    input wire logic in,
    output      logic out, 
    output logic on_up
    );
    
    // sync with clock, to become synchronous and avoid metastability
    // 2 ff synchronizer
    logic sync_0, sync_1;
    always_ff @(posedge clk) sync_0 <= in; 
    always_ff @(posedge clk) sync_1 <= sync_0; 
    
    // Counter to introduce 10ms delay at 100MHZ
    logic [19:0] cnt; 
    logic idle, max; 
    
    
    // set on_up when not idle, and max  and out 
    // so this button will need a press, then for the delay to run out in order to register a signal
    always_comb begin
        idle = (out == sync_1);
        max = &cnt;
        on_up = ~idle & max & out;
    end
    
    
    // only decrement delay when we are not in idle 
    // toggle out if max is reached
    always_ff @(posedge clk) begin 
        if(idle || rst) begin
            cnt <= 0; 
        end else begin 
            cnt <= cnt + 1; 
            if(max) out <= ~out;
        end 
    end
    
endmodule
