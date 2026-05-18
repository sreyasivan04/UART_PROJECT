`timescale 1ns / 1ps

module u_xmit #(parameter WORD_LEN=8)(
input sys_rst_l,
input baud_16,
input xmitH,
input [WORD_LEN-1:0] xmit_dataH,
output reg xmit_doneH,
output reg uart_XMIT_dataH,
output reg xmit_active
);

localparam IDLE=2'd0;
localparam START=2'd1;
localparam SHIFT=2'd2;
localparam STOP=2'd3;

reg [1:0] state;
reg [WORD_LEN-1:0] shift_reg;
reg [$clog2(WORD_LEN)-1:0] bit_count;
reg [3:0] baud_count;

always @(posedge baud_16 or negedge sys_rst_l)
begin

if(!sys_rst_l)
begin
state<=IDLE;
bit_count<=0;
baud_count<=0;
shift_reg<=0;
xmit_doneH<=1'b0;
uart_XMIT_dataH<=1'b1;
xmit_active<=1'b0;
end

else
begin

case(state)

IDLE:
begin
xmit_active<=1'b0;
uart_XMIT_dataH<=1'b1;
baud_count<=0;
bit_count<=0;

if(xmitH==1'b1)
begin
xmit_doneH<=1'b0;
shift_reg<=xmit_dataH;
uart_XMIT_dataH<=1'b0;
xmit_active<=1'b1;
state<=START;
end

end

START:
begin

xmit_active<=1'b1;

if(baud_count==4'd15)
begin
uart_XMIT_dataH<=shift_reg[0];
baud_count<=0;
state<=SHIFT;
end

else
begin
baud_count<=baud_count+1;
end

end

SHIFT:
begin

xmit_active<=1'b1;

if(baud_count==4'd15)
begin

shift_reg<=shift_reg>>1;
baud_count<=0;

if(bit_count==WORD_LEN-1)
begin
uart_XMIT_dataH<=1'b1;
state<=STOP;
end

else
begin
bit_count<=bit_count+1;
uart_XMIT_dataH<=shift_reg[1];
end

end

else
begin
baud_count<=baud_count+1;
end

end

STOP:
begin

xmit_active<=1'b1;

if(baud_count==4'd15)
begin
xmit_doneH<=1'b1;
xmit_active<=1'b0;
baud_count<=0;
state<=IDLE;
end

else
begin
baud_count<=baud_count+1;
end

end

default:
begin
state<=IDLE;
bit_count<=0;
baud_count<=0;
shift_reg<=0;
uart_XMIT_dataH<=1'b1;
xmit_doneH<=1'b0;
xmit_active<=1'b0;
end

endcase

end

end

endmodule
