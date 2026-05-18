`timescale 1ns / 1ps

module uart_top #(

parameter WORD_LEN  = 8,
parameter baud_rate = 9600,
parameter XTAL_CLK  = 50000000

)(

input sys_clk,
input sys_rst_l,

input xmitH,
input [WORD_LEN-1:0] xmit_dataH,

output uart_XMIT_dataH,
output xmit_doneH,
output xmit_active,

output rec_readyH,
output rec_busyH,
output [WORD_LEN-1:0] rec_dataH

);

wire baud_16;

baud #(

.XTAL_CLK (XTAL_CLK),
.baud_rate(baud_rate)

) u_baud (

.sys_clk   (sys_clk),
.sys_rst_l (sys_rst_l),
.baud_16   (baud_16)

);

u_xmit #(

.WORD_LEN(WORD_LEN)

) u_tx (

.sys_rst_l       (sys_rst_l),
.baud_16         (baud_16),
.xmitH           (xmitH),
.xmit_dataH      (xmit_dataH),

.xmit_doneH      (xmit_doneH),
.uart_XMIT_dataH (uart_XMIT_dataH),
.xmit_active     (xmit_active)

);

u_rec #(

.WORD_LEN(WORD_LEN)

) u_rx (

.sys_rst_l      (sys_rst_l),
.uart_REC_dataH (uart_XMIT_dataH),
.baud_16        (baud_16),

.rec_dataH      (rec_dataH),
.rec_readyH     (rec_readyH),
.rec_busyH      (rec_busyH)

);

endmodule
