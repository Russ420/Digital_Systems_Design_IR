module ir_pos
(
    input       CLOCK_50,
    input       rst_n,
    input       IRDA_RXD,
    input       ir_neg,

    output reg  ir_pos,
    output reg  ir_pos_flag
);
reg     ir_1d;
reg     ir_2d;
reg     ir_3d;

ir_neg ir_neg_inst_I
(
    .CLOCK_50(CLOCK_50),
    .rst_n(rst_n),
    .IRDA_RXD(IRDA_RXD),
    .ir_neg(ir_neg)
);

always @(posedge CLOCK_50 or negedge rst_n)begin
    if(!rst_n)begin
        ir_1d <= 1'b0;
    end
    else begin
        ir_1d <= IRDA_RXD;
    end
end
always @(posedge CLOCK_50 or negedge rst_n)begin
    if(!rst_n)begin
        ir_2d <= 1'b0;
    end
    else begin
        ir_2d <= ir_1d;
    end
end
always @(posedge CLOCK_50 or negedge rst_n)begin
    if(!rst_n)begin
        ir_3d <= 1'b0;
    end
    else begin
        ir_3d <= ir_2d;
    end
end
always @(posedge CLOCK_50 or negedge rst_n)begin
    if(!rst_n)begin
        ir_pos <= 1'b0;
    end
    else begin
        ir_pos <= ir_2d & !ir_3d;
    end
end
always @(posedge CLOCK_50 or negedge rst_n)begin
    if(!rst_n)begin
        ir_pos_flag <= 1'b0;
    end
    else begin
        case({ir_pos, ir_neg})
            2'b00:begin
                ir_pos_flag <= 1'b0;
            end
            2'b01:begin
                ir_pos_flag <= 1'b0;
            end
            2'b10:begin
                ir_pos_flag <= 1'b1;
            end
            2'b11:begin     // warning
                ir_pos_flag <= 1'b0;
            end
            default:begin
                ir_pos_flag <= ir_pos_flag;         
            end
        endcase
    end
end

endmodule 