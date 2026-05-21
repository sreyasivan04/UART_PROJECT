`timescale 1ns / 1ps

module uart_tb;

parameter data_width = 8;

reg sys_clk;
reg sys_rst_l;

reg xmitH;
reg [data_width-1:0] xmit_dataH;



wire dut_uart_xmit_datah;
wire dut_xmit_doneH;
wire dut_xmit_active;

wire dut_rec_readyh;
wire dut_rec_busyh;
wire [data_width-1:0] dut_rec_datah;



wire ref_uart_xmit_datah;
wire ref_xmit_doneH;
wire ref_xmit_active;

wire ref_rec_readyh;
wire ref_rec_busyh;
wire [data_width-1:0] ref_rec_datah;

wire ref_uart_clk;



initial
begin
    sys_clk = 0;
    forever #5 sys_clk = ~sys_clk;
end



uart_top DUT (

.sys_clk(sys_clk),
.sys_rst_l(sys_rst_l),

.xmitH(xmitH),
.xmit_dataH(xmit_dataH),

.uart_XMIT_dataH(dut_uart_xmit_datah),
.xmit_doneH(dut_xmit_doneH),
.xmit_active(dut_xmit_active),

.rec_readyH(dut_rec_readyh),
.rec_busyH(dut_rec_busyh),
.rec_dataH(dut_rec_datah)

);



uart_refrence REF (

.sys_clk(sys_clk),
.sys_rst_l(sys_rst_l),

.xmitH(xmitH),
.xmit_dataH(xmit_dataH),

.uart_REC_dataH(ref_uart_xmit_datah),

.uart_XMIT_dataH(ref_uart_xmit_datah),
.xmit_doneH(ref_xmit_doneH),
.xmit_active(ref_xmit_active),

.rec_readyH(ref_rec_readyh),
.rec_busyH(ref_rec_busyh),
.rec_dataH(ref_rec_datah),

.uart_clk_out(ref_uart_clk)

);



integer pass_count;
integer fail_count;
integer test_count;



initial
begin
    $dumpfile("uart_tb.vcd");
    $dumpvars(0,uart_tb);
end



function compare_tx;

input dut_done;
input dut_active;
input dut_serial;

input ref_done;
input ref_active;
input ref_serial;

begin

compare_tx =
(dut_done   === ref_done)   &&
(dut_active === ref_active) &&
(dut_serial === ref_serial);

end
endfunction



function compare_rx;

input dut_ready;
input dut_busy;
input [data_width-1:0] dut_data;

input ref_ready;
input ref_busy;
input [data_width-1:0] ref_data;

begin

compare_rx =
(dut_ready === ref_ready) &&
(dut_busy  === ref_busy)  &&
(dut_data  === ref_data);

end
endfunction



task display_tx_mismatch;

begin

$display("DUT TX : done=%b active=%b serial=%b",
dut_xmit_doneH,
dut_xmit_active,
dut_uart_xmit_datah);

$display("REF TX : done=%b active=%b serial=%b",
ref_xmit_doneH,
ref_xmit_active,
ref_uart_xmit_datah);

end
endtask



task display_rx_mismatch;

begin

$display("DUT RX : ready=%b busy=%b data=0x%02X",
dut_rec_readyh,
dut_rec_busyh,
dut_rec_datah);

$display("REF RX : ready=%b busy=%b data=0x%02X",
ref_rec_readyh,
ref_rec_busyh,
ref_rec_datah);

end
endtask



task wait_tx_complete;

begin

wait(dut_xmit_active == 1'b0);
wait(ref_xmit_active == 1'b0);

repeat(5) @(posedge ref_uart_clk);

end
endtask



task apply_test_tx;

input [data_width-1:0] data;
input [200:1] test_name;

begin

wait(dut_xmit_active == 1'b0);
wait(ref_xmit_active == 1'b0);

@(posedge ref_uart_clk);

xmit_dataH = data;
xmitH = 1'b1;

@(posedge ref_uart_clk);

xmitH = 1'b0;

wait_tx_complete;

test_count = test_count + 1;

if(compare_tx(

dut_xmit_doneH,
dut_xmit_active,
dut_uart_xmit_datah,

ref_xmit_doneH,
ref_xmit_active,
ref_uart_xmit_datah

))

begin

$display("[PASS] %s data=0x%02X",test_name,data);

pass_count = pass_count + 1;

end

else

begin

$display("[FAIL] %s data=0x%02X",test_name,data);

display_tx_mismatch;

fail_count = fail_count + 1;

end

end
endtask



task wait_rx_complete;

integer timeout;

begin

timeout = 0;

while(
(dut_rec_readyh != 1'b1) ||
(ref_rec_readyh != 1'b1)
)

begin

@(posedge ref_uart_clk);

timeout = timeout + 1;

if(timeout > 5000)
begin
$display("RX TIMEOUT");
disable wait_rx_complete;
end

end

end
endtask



task apply_test_rx;

input [data_width-1:0] data;
input [200:1] test_name;

begin

force DUT.u_rx.rec_ff2 = 1'b0;

repeat(16) @(posedge ref_uart_clk);

force DUT.u_rx.rec_ff2 = data[0];
repeat(16) @(posedge ref_uart_clk);

force DUT.u_rx.rec_ff2 = data[1];
repeat(16) @(posedge ref_uart_clk);

force DUT.u_rx.rec_ff2 = data[2];
repeat(16) @(posedge ref_uart_clk);

force DUT.u_rx.rec_ff2 = data[3];
repeat(16) @(posedge ref_uart_clk);

force DUT.u_rx.rec_ff2 = data[4];
repeat(16) @(posedge ref_uart_clk);

force DUT.u_rx.rec_ff2 = data[5];
repeat(16) @(posedge ref_uart_clk);

force DUT.u_rx.rec_ff2 = data[6];
repeat(16) @(posedge ref_uart_clk);

force DUT.u_rx.rec_ff2 = data[7];
repeat(16) @(posedge ref_uart_clk);

force DUT.u_rx.rec_ff2 = 1'b1;

repeat(16) @(posedge ref_uart_clk);

release DUT.u_rx.rec_ff2;

wait_rx_complete;

test_count = test_count + 1;

if(compare_rx(

dut_rec_readyh,
dut_rec_busyh,
dut_rec_datah,

ref_rec_readyh,
ref_rec_busyh,
ref_rec_datah

))

begin

$display("[PASS] %s data=0x%02X",test_name,data);

pass_count = pass_count + 1;

end

else

begin

$display("[FAIL] %s data=0x%02X",test_name,data);

display_rx_mismatch;

fail_count = fail_count + 1;

end

end
endtask



initial
begin

pass_count = 0;
fail_count = 0;
test_count = 0;

sys_rst_l = 0;

xmitH = 0;
xmit_dataH = 8'h00;

#200;

sys_rst_l = 1;

repeat(10) @(posedge ref_uart_clk);

$display("--------------------------------");
$display("UART TRANSMITTER TESTS");
$display("--------------------------------");

apply_test_tx(8'hA5,"TX A5");
apply_test_tx(8'h3C,"TX 3C");
apply_test_tx(8'h00,"TX 00");
apply_test_tx(8'hFF,"TX FF");
apply_test_tx(8'h55,"TX 55");
apply_test_tx(8'hAA,"TX AA");



$display("--------------------------------");
$display("UART RECEIVER TESTS");
$display("--------------------------------");

apply_test_rx(8'hA5,"RX A5");
apply_test_rx(8'h3C,"RX 3C");
apply_test_rx(8'h00,"RX 00");
apply_test_rx(8'hFF,"RX FF");
apply_test_rx(8'h55,"RX 55");
apply_test_rx(8'hAA,"RX AA");



$display("--------------------------------");
$display("TOTAL TESTS : %0d",test_count);
$display("PASS        : %0d",pass_count);
$display("FAIL        : %0d",fail_count);

if(fail_count == 0)
$display("ALL TESTS PASSED");

else
$display("SOME TESTS FAILED");

$display("--------------------------------");

#1000;

$finish;

end



initial
begin

#50000000;

$display("SIMULATION TIMEOUT");

$finish;

end

endmodule
