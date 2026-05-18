`timescale 1ns / 1ps

module u_rec #(parameter WORD_LEN=8)(

input sys_rst_l,
input uart_REC_dataH,
input baud_16,

output reg [WORD_LEN-1:0] rec_dataH,
output reg rec_readyH,
output reg rec_busyH

);

localparam idle      = 2'd0;
localparam start_bit = 2'd1;
localparam data_bit  = 2'd2;
localparam stop_bit  = 2'd3;

reg rec_ff1;
reg rec_ff2;

reg [1:0] state;
reg [WORD_LEN-1:0] shift_reg;
reg [$clog2(WORD_LEN)-1:0] bit_count;
reg [3:0] baud_count;

always @(posedge baud_16 or negedge sys_rst_l)
begin
    if(!sys_rst_l)
    begin
        state       <= idle;
        rec_ff1     <= 1'b1;
        rec_ff2     <= 1'b1;
        rec_dataH   <= 0;
        rec_readyH  <= 1'b0;
        rec_busyH   <= 1'b0;
        shift_reg   <= 0;
        bit_count   <= 0;
        baud_count  <= 0;
    end
    else
    begin
        rec_ff1 <= uart_REC_dataH;
        rec_ff2 <= rec_ff1;
        case(state)
        idle:
        begin
            rec_readyH <= 1'b0;
            rec_busyH  <= 1'b0;
            bit_count  <= 0;
            baud_count <= 0;
            if(rec_ff2 == 1'b0)
            begin
                rec_busyH <= 1'b1;
                state <= start_bit;
            end
        end
        start_bit:
        begin
            rec_busyH <= 1'b1;
            if(baud_count == 4'd7)
            begin
                if(rec_ff2 == 1'b0)
                begin
                    baud_count <= 0;
                    state <= data_bit;
                end
                else
                begin
                    state <= idle;
                end
            end
            else
            begin
                baud_count <= baud_count + 1;
            end
        end
        data_bit:
        begin
            rec_busyH <= 1'b1;
            if(baud_count == 4'd15)
            begin
                baud_count <= 0;
                shift_reg <= {shift_reg[WORD_LEN-2:0], rec_ff2};
                if(bit_count == WORD_LEN-1)
                begin
                    bit_count <= 0;
                    state <= stop_bit;
                end
                else
                begin
                    bit_count <= bit_count + 1;
                end
            end
            else
            begin
                baud_count <= baud_count + 1;
            end
        end
        stop_bit:
        begin
            rec_busyH <= 1'b1;
            if(baud_count == 4'd15)
            begin
                baud_count <= 0;
                if(rec_ff2 == 1'b1)
                begin
                    rec_dataH <= shift_reg;
                    rec_readyH <= 1'b1;
                end
                rec_busyH <= 1'b0;
                state <= idle;
            end
            else
            begin

                baud_count <= baud_count + 1;

            end

        end

        default:
        begin

            state <= idle;

        end

        endcase

    end

end

endmodule
