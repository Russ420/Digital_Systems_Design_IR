module us_50_cnt
(
    input       CLOCK_50,
    input       rst_n,
    input       IRDA_RXD,
    
    output      pos_check_0_O,
    output      pos_check_1_O,
    output      neg_check_O,
    output      vaild_sig_0_O,
    output      vaild_sig_1_O
);

wire    ir_pos_50;
wire    ir_neg_50;

ir_edge ir_edge_inst_I
(
    .CLOCK_50(CLOCK_50),
    .rst_n(rst_n),
    .IRDA_RXD(IRDA_RXD),
    .ir_pos_O(ir_pos_50),
    .ir_neg_O(ir_neg_50)
);

reg     pos_check_0;
reg     pos_check_1;
reg     neg_check;
reg     vaild_sig_0;
reg     vaild_sig_1;
reg     [5:0]parity_np;
reg     [5:0]order_50us_p;
reg     [5:0]order_50us_n;
reg     [11:0]covert_50us_p;
reg     [11:0]covert_50us_n;

assign  pos_check_0_O = pos_check_0;
assign  pos_check_1_O = pos_check_1;
assign  neg_check_O   = neg_check;
assign  vaild_sig_0_O = vaild_sig_0;
assign  vaild_sig_1_O = vaild_sig_1;

always @(posedge CLOCK_50 or negedge rst_n)begin
    if(!rst_n)begin
        covert_50us_n <= 12'd0;
        order_50us_n <= 6'd0;
    end
    else begin
        casez({ir_neg_50, covert_50us_n})
            13'b1_????_????_????:begin
                covert_50us_n <= 12'd0;
                order_50us_n  <= 6'd0;
            end
            13'b0_1001_1100_0011:begin
                covert_50us_n  <= 12'd0;
                order_50us_n   <= order_50us_n + 6'd1;
            end
            13'b0_????_????_????:begin
                covert_50us_n <= covert_50us_n + 12'd1;
            end
            default:begin
                covert_50us_n <= covert_50us_n;
            end
        endcase
    end
end
always @(posedge CLOCK_50 or negedge rst_n)begin
    if(!rst_n)begin
        covert_50us_p <= 12'h0;
        order_50us_p <= 6'h0;
    end
    else begin
        casez({ir_neg_50, ir_pos_50, covert_50us_p})
            14'b1?_????_????_????:begin
                covert_50us_p <= 12'd0;
                order_50us_p  <= 6'd0;
            end
            14'b?1_????_????_????:begin
                covert_50us_p <= 12'd0;
                order_50us_p <= 6'd0;
            end
            14'b00_1001_1100_0011:begin
                covert_50us_p  <= 12'd0;
                order_50us_p   <= order_50us_p + 6'd1;
            end
            14'b00_????_????_????:begin
                covert_50us_p <= covert_50us_p + 12'd1;
            end
            default:begin
                covert_50us_p <= covert_50us_p;
            end
        endcase
    end
end
always @(posedge CLOCK_50 or negedge rst_n)begin
    if(!rst_n)begin
        parity_np <= 6'd0;
    end
    else begin
        if(ir_neg_50)begin
            parity_np <= 6'd0;
        end
        else begin    
            if(order_50us_n < order_50us_p)begin
                parity_np <= ~(order_50us_n - order_50us_p) + 6'd1;
            end
            else begin
                parity_np <= order_50us_n - order_50us_p;
            end
        end
    end
end
always @(posedge CLOCK_50 or negedge rst_n)begin // center b
    if(!rst_n)begin
        pos_check_0 <= 1'b0;
    end
    else begin
        if(order_50us_p > 6'h7 && order_50us_p < 6'hf)begin
            pos_check_0 <= 1'b1;
        end
        else begin
            pos_check_0 <= 1'b0;
        end
    end
end
always @(posedge CLOCK_50 or negedge rst_n)begin
    if(!rst_n)begin
        pos_check_1 <= 1'b0;
    end
    else begin
        if(order_50us_p > 6'h1d && order_50us_p < 6'h25)begin // center 21
            pos_check_1 <= 1'b1;
        end
        else begin
            pos_check_1 <= 1'b0;
        end
    end
end
always @(posedge CLOCK_50 or negedge rst_n)begin // center b
    if(!rst_n)begin
        neg_check <= 1'b0;
    end
    else begin
        if(parity_np > 6'h7 && parity_np < 6'hf)begin
            neg_check <= 1'b1;
        end
        else begin
            neg_check <= 1'b0;
        end
    end
end

always @(posedge CLOCK_50 or negedge rst_n)begin
    if(!rst_n)begin
        vaild_sig_0 <= 1'b0;
    end
    else begin
        if(pos_check_0 && neg_check && ir_neg_50)begin
            vaild_sig_0 <= 1'b1;
        end
        else begin
            vaild_sig_0 <= 1'b0;
        end
    end
end
always @(posedge CLOCK_50 or negedge rst_n)begin
    if(!rst_n)begin
        vaild_sig_1 <= 1'b0;
    end
    else begin
        if(pos_check_1 && neg_check && ir_neg_50)begin
            vaild_sig_1 <= 1'b1;
        end
        else begin
            vaild_sig_1 <= 1'b0;
        end
    end
end

endmodule 