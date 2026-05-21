`timescale 1ns/1ns

module uart_tb;

parameter FREQ  = 50000000;
parameter BAUDR = 9600;
parameter WIDTH = 8;

reg sys_clk;
reg sys_rst_l;
reg xmitH;
reg [WIDTH-1:0] xmit_dataH;
reg uart_REC_dataH;

wire uart_XMIT_dataH;
wire xmit_doneH;
wire xmit_active;
wire rec_readyH;
wire rec_busy;
wire [WIDTH-1:0] rec_dataH;

wire baud_en;

integer pass_count=0;
integer fail_count=0;
integer test_num=0;

reg uart_clk_prev;

initial sys_clk=0;
always #10 sys_clk=~sys_clk;

uart #(
.WORD_LEN(WIDTH),
.BAUD_RATE(BAUDR),
.XTAL_CLK(FREQ)
) u_dut (
.sys_clk(sys_clk),
.sys_rst_l(sys_rst_l),
.xmitH(xmitH),
.xmit_dataH(xmit_dataH),
.uart_XMIT_dataH(uart_XMIT_dataH),
.xmit_doneH(xmit_doneH),
.xmit_active(xmit_active),
.uart_REC_dataH(uart_REC_dataH),
.rec_readyH(rec_readyH),
.rec_busy(rec_busy),
.rec_dataH(rec_dataH)
);

assign baud_en = u_dut.BAUD.uart_clk;

uart_reference #(
.b(WIDTH)
) u_ref (
.sys_clk(sys_clk),
.baud_en(baud_en),
.rst(sys_rst_l),
.xmitH(xmitH),
.data_in(xmit_dataH),
.serial_in(uart_XMIT_dataH),
.exp_rec_dataH(),
.exp_rec_readyH(),
.exp_rec_busy(),
.exp_xmit_active(),
.exp_xmit_doneH()
);

always @(*)
begin
uart_REC_dataH = uart_XMIT_dataH;
end

task driver_send;
input [WIDTH-1:0] data;
begin
@(posedge baud_en);
xmit_dataH = data;
xmitH = 1'b1;
@(posedge baud_en);
xmitH = 1'b0;
@(posedge xmit_doneH);
repeat(20) @(posedge baud_en);
end
endtask

task checker;
input [WIDTH-1:0] sent_data;
begin
test_num = test_num + 1;
#1;
if(rec_dataH === sent_data)
begin
$display("PASS [%0d] SENT=%h REC=%h",
test_num,sent_data,rec_dataH);
pass_count = pass_count + 1;
end
else
begin
$display("FAIL [%0d] SENT=%h REC=%h",
test_num,sent_data,rec_dataH);
fail_count = fail_count + 1;
end
end
endtask

reg [WIDTH-1:0] last_sent;

always @(posedge rec_readyH)
begin
checker(last_sent);
end

initial
begin

sys_rst_l = 1'b0;
xmitH = 1'b0;
xmit_dataH = 0;
last_sent = 0;

repeat(20) @(posedge sys_clk);

sys_rst_l = 1'b1;

repeat(10) @(posedge baud_en);

last_sent=8'h00; driver_send(8'h00);
last_sent=8'hff; driver_send(8'hff);
last_sent=8'h55; driver_send(8'h55);
last_sent=8'haa; driver_send(8'haa);
last_sent=8'h0f; driver_send(8'h0f);
last_sent=8'hf0; driver_send(8'hf0);
last_sent=8'h24; driver_send(8'h24);
last_sent=8'h81; driver_send(8'h81);
last_sent=8'h09; driver_send(8'h09);
last_sent=8'h63; driver_send(8'h63);
last_sent=8'h0d; driver_send(8'h0d);
last_sent=8'h8d; driver_send(8'h8d);
last_sent=8'h65; driver_send(8'h65);
last_sent=8'h12; driver_send(8'h12);
last_sent=8'h01; driver_send(8'h01);
last_sent=8'h76; driver_send(8'h76);
last_sent=8'h3d; driver_send(8'h3d);
last_sent=8'hed; driver_send(8'hed);
last_sent=8'h8c; driver_send(8'h8c);
last_sent=8'hf9; driver_send(8'hf9);
last_sent=8'hc6; driver_send(8'hc6);
last_sent=8'haa; driver_send(8'haa);
last_sent=8'he5; driver_send(8'he5);
last_sent=8'h77; driver_send(8'h77);
last_sent=8'h12; driver_send(8'h12);
last_sent=8'h8f; driver_send(8'h8f);
last_sent=8'hf2; driver_send(8'hf2);
last_sent=8'hce; driver_send(8'hce);
last_sent=8'he8; driver_send(8'he8);

force u_dut.TX.state = 2'b11;
@(posedge baud_en);
release u_dut.TX.state;

repeat(5) @(posedge baud_en);

force u_dut.RX.state = 2'b11;
@(posedge baud_en);
release u_dut.RX.state;

repeat(5) @(posedge baud_en);

force u_dut.TX.state = 2'b10;
force u_dut.TX.uart_count = 4'd15;
force u_dut.TX.bit_count = WIDTH-1;

@(posedge baud_en);

release u_dut.TX.state;
release u_dut.TX.uart_count;
release u_dut.TX.bit_count;

repeat(5) @(posedge baud_en);

force u_dut.RX.state = 2'b10;
force u_dut.RX.uart_count = 4'd15;
force u_dut.RX.rec_ff2 = 1'b0;

@(posedge baud_en);

release u_dut.RX.state;
release u_dut.RX.uart_count;
release u_dut.RX.rec_ff2;

repeat(20) @(posedge baud_en);

$display("======================================");
$display("TOTAL TESTS = %0d",test_num);
$display("PASS        = %0d",pass_count);
$display("FAIL        = %0d",fail_count);
$display("======================================");

$finish;

end

endmodule
