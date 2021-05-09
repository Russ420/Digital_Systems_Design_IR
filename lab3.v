module lab3
(
    input       CLOCK_50,
    input       rst_n,
    input       IRDA_RXD,

    output      LCD_RS,
    output      LCD_RW,
    output      LCD_EN,
    output      [7:0]LCD_DATA,    
    output      LCD_ON,
    output      LCD_BLON,
    output      [7:0]LEDG,
    output      [6:0]HEX0,
    output      [6:0]HEX1,
    output      [6:0]HEX2,
    output      [6:0]HEX3,
    output      [6:0]HEX4,
    output      [6:0]HEX5,
    output      [6:0]HEX6,
    output      [6:0]HEX7,
    output      [3:0]KEY
);

wire    lead_flag_top;
wire    [5:0]vaild_cnt_top;
wire    [3:0]clu_top;
wire    [3:0]cll_top;
wire    [3:0]cru_top;
wire    [3:0]crl_top;
wire    [3:0]ku_top;
wire    [3:0]kl_top;
wire    [3:0]iku_top;
wire    [3:0]ikl_top;
wire    clear_sig_top;


LCM_controller LCM_controller_inst_I
(
    .CLOCK_50(CLOCK_50),
    .rst_n(rst_n),
    .IRDA_RXD(IRDA_RXD),
    .LCD_RS(LCD_RS),
    .LCD_RW(LCD_RW),
    .LCD_EN(LCD_EN),
    .LCD_DATA(LCD_DATA),    
    .LCD_ON(LCD_ON),
    .LCD_BLON(LCD_BLON),
    .lead_flag_O(lead_flag_top),
    .vaild_cnt_O(vaild_cnt_top),
    .clu_O(clu_top),
    .cll_O(cll_top),
    .cru_O(cru_top),
    .crl_O(crl_top),
    .ku_O(ku_top),
    .kl_O(kl_top),
    .iku_O(iku_top),
    .ikl_O(ikl_top),
    .clear_sig_O(clear_sig_top)
);

assign  LEDG[0] = lead_flag_top;
assign  LEDG[1] = clear_sig_top;
assign  KEY[0]  = rst_n;

SEG_HEX l0  (clu_top, HEX7);
SEG_HEX l1  (cll_top, HEX6);
SEG_HEX l2  (cru_top, HEX5);
SEG_HEX l3  (crl_top, HEX4);
SEG_HEX l4  (ku_top, HEX3);
SEG_HEX l5  (kl_top, HEX2);
SEG_HEX l6  (iku_top, HEX1);
SEG_HEX l7  (ikl_top, HEX0);

endmodule 