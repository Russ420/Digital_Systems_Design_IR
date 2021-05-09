module us_500_cnt
(
    input       CLOCK_50,
    input       rst_n,
    input       IRDA_RXD,
    output      pos_check_O,
    output      neg_check_O,
    output      ir_neg_500_O
);

wire    ir_pos_500;
wire    ir_neg_500;

ir_edge ir_edge_inst_I
(
    .CLOCK_50(CLOCK_50),
    .rst_n(rst_n),
    .IRDA_RXD(IRDA_RXD),
    .ir_pos_O(ir_pos_500),
    .ir_neg_O(ir_neg_500)
);

reg     pos_check;
reg     neg_check;
reg     [4:0]parity_np;
reg     [4:0]order_500us_p;
reg     [4:0]order_500us_n;
reg     [15:0]covert_500us_p;
reg     [15:0]covert_500us_n;

assign  pos_check_O  = pos_check;
assign  neg_check_O  = neg_check;
assign  ir_neg_500_O = ir_neg_500;

always @(posedge CLOCK_50 or negedge rst_n)begin
    if (!rst_n) begin
       covert_500us_n   <= 16'd0;
       order_500us_n    <= 5'd0;
    end
    else begin
        casez({ir_neg_500, covert_500us_n}) //16 + 1
            17'b1_????_????_????_????:begin
                covert_500us_n <= 16'd0;
                order_500us_n  <= 5'd0;
            end
            17'b0_0110_0001_1010_0111:begin
                covert_500us_n  <= 16'd0;
                order_500us_n   <= order_500us_n + 5'd1;
            end
            17'b0_????_????_????_????:begin
                covert_500us_n <= covert_500us_n + 16'd1;
            end
            default:begin
                covert_500us_n <= covert_500us_n;
            end
        endcase
    end
end
always @(posedge CLOCK_50 or negedge rst_n)begin
    if (!rst_n) begin
       covert_500us_p   <= 16'd0;
       order_500us_p    <= 5'd0;
    end
    else begin
        casez({ir_neg_500, ir_pos_500, covert_500us_p}) // 16 + 1 + 1
            18'b1?_????_????_????_????:begin   // ir_neg will clear all
                covert_500us_p <= 16'd0;
                order_500us_p  <= 5'd0;
            end
            18'b?1_????_????_????_????:begin 
                covert_500us_p <= 16'd0;
                order_500us_p  <= 5'd0;
            end
            18'b00_0110_0001_1010_0111:begin
                covert_500us_p  <= 16'd0;
                order_500us_p   <= order_500us_p + 5'd1;
            end
            18'b00_????_????_????_????:begin
                covert_500us_p <= covert_500us_p + 16'd1;
            end
            default:begin
                covert_500us_p <= covert_500us_p;
            end
        endcase
    end
end
always @(posedge CLOCK_50 or negedge rst_n)begin
    if(!rst_n)begin
        parity_np <= 5'd0;
    end
    else begin
        if(ir_neg_500)begin
            parity_np <= 5'd0;
        end
        else begin    
            if(order_500us_n < order_500us_p)begin
                parity_np <= ~(order_500us_n - order_500us_p) + 5'd1;
            end
            else begin
                parity_np <= order_500us_n - order_500us_p;
            end
        end
    end
end
always @(posedge CLOCK_50 or negedge rst_n)begin // 12 center
    if(!rst_n)begin
        neg_check <= 1'b0;
    end
    else begin
        if(parity_np > 5'h10 && parity_np < 5'h14)begin
            neg_check <= 1'b1;
        end
        else begin
            neg_check <= 1'b0;
        end
    end
end
always @(posedge CLOCK_50 or negedge rst_n)begin
    if(!rst_n)begin
        pos_check <= 1'b0;
    end
    else begin
        if(order_500us_p > 5'h6 && order_500us_p < 5'ha)begin // 8 center
            pos_check <= 1'b1;
        end
        else begin
            pos_check <= 1'b0;
        end
    end
end

endmodule 