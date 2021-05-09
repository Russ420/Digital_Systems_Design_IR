module ir_leader_check
(
    input       CLOCK_50,
    input       rst_n,
    input       IRDA_RXD,
    output      ir_leader_check_O,
    output      ir_neg_ldr_O
);

wire    pos_check_ldr;
wire    neg_check_ldr;
wire    ir_neg_500_ldr;

us_500_cnt us_500_cnt_inst_I
(
    .CLOCK_50(CLOCK_50),
    .rst_n(rst_n),
    .IRDA_RXD(IRDA_RXD),
    .pos_check_O(pos_check_ldr),
    .neg_check_O(neg_check_ldr),
    .ir_neg_500_O(ir_neg_500_ldr)
);

reg     ir_leader_check;

assign  ir_leader_check_O = ir_leader_check;
assign  ir_neg_ldr_O      = ir_neg_500_ldr;

always @(posedge CLOCK_50 or negedge rst_n)begin
    if(!rst_n)begin
        ir_leader_check <= 1'b0;
    end
    else begin
        if(pos_check_ldr && neg_check_ldr && ir_neg_500_ldr)begin
            ir_leader_check <= 1'b1;
        end
        else begin
            ir_leader_check <= 1'b0;
        end
    end
end

endmodule 