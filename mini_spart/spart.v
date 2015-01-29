`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:   
// Design Name: 
// Module Name:    spart 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module spart(
    input clk,
    input rst,
    input iocs,
    input iorw,
    output rda,
    output tbr,
    input [1:0] ioaddr,
    inout [7:0] databus,
    output txd,
    input rxd
    );

    bus_interface bus0( .iocs(),
                        .iorw(),
                        .ioaddr(),
                        .rda(),
                        .tbr(),
                        .databus(),
                        .data_in(),
                        .data_out(),
                        .wrt_db_low(),
                        .wrt_db_high(),
                        .wrt_tx()
                        );


endmodule
