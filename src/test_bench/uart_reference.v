`timescale 1ns/1ns

module uart_reference #(parameter b=8)(

input sys_clk,
input baud_en,
input rst,

input xmitH,
input [b-1:0] data_in,

input serial_in,

output reg [b-1:0] exp_rec_dataH,
output reg exp_rec_readyH,
output reg exp_rec_busy,

output reg exp_xmit_active,
output reg exp_xmit_doneH

);

reg [4:0] count;
reg busy;

function [b-1:0] dut_style_reverse;

input [b-1:0] din;

integer i;

begin

    for(i=0;i<b;i=i+1)
        dut_style_reverse[i] = din[b-1-i];

end

endfunction

always @(posedge sys_clk or negedge rst)
begin

    if(!rst)
    begin

        exp_rec_dataH  <= 0;

        exp_rec_readyH <= 0;
        exp_rec_busy   <= 0;

        exp_xmit_active <= 0;
        exp_xmit_doneH  <= 1;

        count <= 0;
        busy  <= 0;

    end

    else if(baud_en)
    begin

       
        if(xmitH && !busy)
        begin

            busy <= 1;

            count <= 0;

            exp_xmit_active <= 1;
            exp_xmit_doneH  <= 0;

            exp_rec_busy   <= 1;
            exp_rec_readyH <= 0;

        end

       
        else if(busy)
        begin

            count <= count + 1;

           
            if(count == 9)
            begin

                busy <= 0;

                exp_xmit_active <= 0;
                exp_xmit_doneH  <= 1;

                exp_rec_busy   <= 0;
                exp_rec_readyH <= 1;

                
                exp_rec_dataH <= dut_style_reverse(data_in);

            end

        end

    end

end

endmodule
