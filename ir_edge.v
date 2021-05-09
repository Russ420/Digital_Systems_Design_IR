module ir_edge
(
    input       CLOCK_50,
    input       rst_n,
    input       IRDA_RXD,

    output      ir_pos_O,
    output      ir_neg_O    
);

reg     ir_1d;
reg     ir_2d;
reg     ir_3d;
reg     ir_pos;
reg     ir_neg;

assign      ir_pos_O = ir_pos;
assign      ir_neg_O = ir_neg;

always @(posedge CLOCK_50 or negedge rst_n)begin    // first latch
    if(!rst_n)begin
        ir_1d <= 1'b0;
    end
    else begin
        ir_1d <= IRDA_RXD;
    end
end
always @(posedge CLOCK_50 or negedge rst_n)begin    // second latch
    if(!rst_n)begin
        ir_2d <= 1'b0;
    end
    else begin
        ir_2d <= ir_1d;
    end
end
always @(posedge CLOCK_50 or negedge rst_n)begin    // third latch
    if(!rst_n)begin
        ir_3d <= 1'b0;
    end
    else begin
        ir_3d <= ir_2d;
    end
end
always @(posedge CLOCK_50 or negedge rst_n)begin    // pos edge
    if(!rst_n)begin
        ir_pos <= 1'b0;
    end
    else begin
        ir_pos <= ir_2d & !ir_3d;
    end
end
always @(posedge CLOCK_50 or negedge rst_n)begin    // neg edge
    if(!rst_n)begin
        ir_neg <= 1'b0;
    end
    else begin
        ir_neg <= !ir_2d & ir_3d;
    end
end

endmodule 