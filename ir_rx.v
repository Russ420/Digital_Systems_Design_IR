module ir_rx
(
    input       CLOCK_50,
    input       rst_n,
    input       IRDA_RXD,

    output      [3:0]clu_O,
    output      [3:0]cll_O,
    output      [3:0]cru_O,
    output      [3:0]crl_O,
    output      [3:0]ku_O,
    output      [3:0]kl_O,
    output      [3:0]iku_O,
    output      [3:0]ikl_O,


    output      lead_flag_O,
    output      [5:0]vaild_cnt_O
);

wire    ir_leader_check_rx;
wire    ir_neg_rx;
wire    pos_check_0_rx;
wire    pos_check_1_rx;
wire    neg_check_rx;
wire    vaild_sig_0_rx;
wire    vaild_sig_1_rx;

ir_leader_check ir_leader_check_inst_I
(
    .CLOCK_50(CLOCK_50),
    .rst_n(rst_n),
    .IRDA_RXD(IRDA_RXD),
    .ir_leader_check_O(ir_leader_check_rx),
    .ir_neg_ldr_O(ir_neg_rx)
);
us_50_cnt us_50_cnt_inst_I
(
    .CLOCK_50(CLOCK_50),
    .rst_n(rst_n),
    .IRDA_RXD(IRDA_RXD),
    .pos_check_0_O(pos_check_0_rx),
    .pos_check_1_O(pos_check_1_rx),
    .neg_check_O(neg_check_rx),
    .vaild_sig_0_O(vaild_sig_0_rx),
    .vaild_sig_1_O(vaild_sig_1_rx)
);

reg     lead_flag;
reg     [24:0]lead_cnt;
reg     time_out;
reg     [7:0]vaild_cnt;
reg     end_sig;
reg     [7:0]custom_l;
reg     [7:0]custom_r;
reg     [7:0]key;
reg     [7:0]inv_key;

assign  cll_O = {custom_l[7], custom_l[6], custom_l[5], custom_l[4]};
assign  clu_O = {custom_l[3], custom_l[2], custom_l[1], custom_l[0]};
assign  crl_O = {custom_r[7], custom_r[6], custom_r[5], custom_r[4]};
assign  cru_O = {custom_r[3], custom_r[2], custom_r[1], custom_r[0]};
assign  kl_O  = {key[7], key[6], key[5], key[4]};
assign  ku_O  = {key[3], key[2], key[1], key[0]};
assign  ikl_O = {inv_key[7], inv_key[6], inv_key[5], inv_key[4]};
assign  iku_O = {inv_key[3], inv_key[2], inv_key[1], inv_key[0]};

assign  lead_flag_O = lead_flag;
assign  vaild_cnt_O = vaild_cnt;


always @(posedge CLOCK_50 or negedge rst_n)begin
    if(!rst_n)begin
        lead_flag <= 1'b0;
    end
    else begin
        case({ir_leader_check_rx, end_sig})
            2'b00:begin
                lead_flag <= lead_flag;
            end
            2'b10:begin
                lead_flag <= 1'b1;
            end
            2'b01:begin
                lead_flag <= 1'b0;
            end
            2'b11:begin
                lead_flag <= 1'b0;
            end
            default:begin
                lead_flag <= lead_flag;
            end
        endcase
    end
end
always @(posedge CLOCK_50 or negedge rst_n)begin
    if(!rst_n)begin
        vaild_cnt <= 8'h0;
    end
    else begin
        if(end_sig)begin
            vaild_cnt <= 8'h0;
        end
        else begin
            case({lead_flag, vaild_sig_0_rx, vaild_sig_1_rx})
                3'b101:begin
                    vaild_cnt <= vaild_cnt + 8'h1;
                end
                3'b110:begin
                    vaild_cnt <= vaild_cnt + 8'h1;
                end 
                3'b111:begin
                    vaild_cnt <= vaild_cnt + 8'h1;
                end
                default:begin
                    vaild_cnt <= vaild_cnt;
                end
            endcase
        end
    end
end
always @(posedge CLOCK_50 or negedge rst_n)begin
    if(!rst_n)begin
        end_sig <= 1'b0;
    end
    else begin
        if(time_out)begin
            end_sig <= 1'b1;
        end
        else begin
            case(vaild_cnt)
                6'h00:begin
                    end_sig <= 1'b0;
                end
                6'h20:begin
                    end_sig <= 1'b1;
                end
                default:begin
                    end_sig <= end_sig;
                end
            endcase 
        end
    end
end
always @(posedge CLOCK_50 or negedge rst_n)begin
    if(!rst_n)begin
        custom_l <= 8'd0;
        custom_r <= 8'd0;
        key <= 8'd0;
        inv_key <= 8'd0;
    end
    else begin
        if(ir_leader_check_rx)begin
            custom_l <= 8'd0;
            custom_r <= 8'd0;
            key <= 8'd0;
            inv_key <= 8'd0;     
        end
        else begin
            case(vaild_cnt)
                32'd0, 32'd1, 32'd2, 32'd3, 32'd4, 32'd5, 32'd6, 32'd7:begin
                    if(vaild_sig_1_rx)begin
                        custom_l[vaild_cnt] <= 1'b1;
                    end
                    else begin
                        custom_l[vaild_cnt] <= 1'b0;
                    end
                end
                32'd8, 32'd9, 32'd10, 32'd11, 32'd12, 32'd13, 32'd14, 32'd15:begin
                    if(vaild_sig_1_rx)begin
                        custom_r[vaild_cnt-8'd8] <= 1'b1;
                    end
                    else begin
                        custom_r[vaild_cnt-8'd8] <= custom_r[vaild_cnt-6'd8];
                    end
                end
                32'd16, 32'd17, 32'd18, 32'd19, 32'd20, 32'd21, 32'd22, 32'd23:begin
                    if(vaild_sig_1_rx)begin
                        key[vaild_cnt-8'd16] <= 1'b1;
                    end
                    else begin
                        key[vaild_cnt-8'd16] <= key[vaild_cnt-6'd16];
                    end
                end
                32'd24, 32'd25, 32'd26, 32'd27, 32'd28, 32'd29, 32'd30, 32'd31:begin
                    if(vaild_sig_1_rx)begin
                        inv_key[vaild_cnt-8'd24] <= 1'b1;
                    end
                    else begin
                        inv_key[vaild_cnt-8'd24] <= inv_key[vaild_cnt-6'd24];
                    end
                end
                default:begin
                    custom_l <= custom_l;
                    custom_r <= custom_r;
                    key <= key;
                    inv_key <= inv_key;
                end
            endcase
        end
    end
end
always @(posedge CLOCK_50 or negedge rst_n)begin
    if(!rst_n)begin
        lead_cnt <= 24'h0;
    end
    else begin
        if(lead_flag)begin
            lead_cnt <= lead_cnt + 24'h1;
        end
        else begin
            lead_cnt <= 24'h0;
        end
    end
end
always @(posedge CLOCK_50 or negedge rst_n)begin
    if(!rst_n)begin
        time_out <= 1'b0;       
    end
    else begin
        if(lead_cnt == 25'h2dc6c0)begin
            time_out <= 1'b1;
        end
        else begin
            time_out <= 1'b0;
        end
    end
end




endmodule 
