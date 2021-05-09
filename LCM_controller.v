module LCM_controller
(
    input       CLOCK_50,
    input       rst_n,
    input       IRDA_RXD,

    output reg  LCD_RS,
    output reg  LCD_RW,
    output reg  LCD_EN,
    output reg  [7:0]LCD_DATA,    
    output reg  LCD_ON,
    output reg  LCD_BLON,
    output      lead_flag_O,
    output      [5:0]vaild_cnt_O,
    output      [3:0]clu_O,
    output      [3:0]cll_O,
    output      [3:0]cru_O,
    output      [3:0]crl_O,
    output      [3:0]ku_O,
    output      [3:0]kl_O,
    output      [3:0]iku_O,
    output      [3:0]ikl_O,
    output      clear_sig_O
);

wire    [3:0]clu_lcm;
wire    [3:0]cll_lcm;
wire    [3:0]cru_lcm;
wire    [3:0]crl_lcm;
wire    [3:0]ku_lcm;
wire    [3:0]kl_lcm;
wire    [3:0]iku_lcm;
wire    [3:0]ikl_lcm;
wire    lead_flag_lcm;
wire    vaild_cnt_lcm;

ir_rx ir_rx_I
(
    .CLOCK_50(CLOCK_50),
    .rst_n(rst_n),
    .IRDA_RXD(IRDA_RXD),
    .clu_O(clu_lcm),
    .cll_O(cll_lcm),
    .cru_O(cru_lcm),
    .crl_O(crl_lcm),
    .ku_O(ku_lcm),
    .kl_O(kl_lcm),
    .iku_O(iku_lcm),
    .ikl_O(ikl_lcm),
    .lead_flag_O(lead_flag_lcm),
    .vaild_cnt_O(vaild_cnt_lcm)
);

reg     init_stage;
reg     ms_pos;
reg     [7:0]ms_cnt;
reg     [4:0]ns_cnt;
reg     [16:0]covert_ns2ms;
reg     clear_sig;

assign  lead_flag_O = lead_flag_lcm;
assign  vaild_cnt_O = vaild_cnt_lcm;
assign  clu_O = clu_lcm;
assign  cll_O = cll_lcm;
assign  cru_O = cru_lcm;
assign  crl_O = crl_lcm;
assign  ku_O  = ku_lcm;
assign  kl_O  = kl_lcm;
assign  iku_O = iku_lcm;
assign  ikl_O = ikl_lcm;
assign  clear_sig_O = clear_sig;

always @(posedge CLOCK_50 or negedge rst_n)begin
    if(!rst_n)begin
        LCD_RS      <= 1'b1;
        LCD_RW      <= 1'b0;
        LCD_EN      <= 1'b0;
        LCD_DATA    <= 8'd0;
        LCD_ON      <= 1'b1;
        LCD_BLON    <= 1'b1;
        ns_cnt      <= 5'd0;
    end
    else begin
        case(init_stage)
            1'b0:begin
                case(ms_cnt)
                    8'h11:begin
                        case(ns_cnt)                        
                            5'd0:begin                      // t_AS             begin
                                LCD_RS  <= 1'b0;
                                LCD_EN  <= 1'b0;
                                ns_cnt  <= ns_cnt + 5'd1;
                            end
                            5'd3:begin                      // PW_EH,t_cycle    begin
                                LCD_EN  <= 1'b1;            // t_AS             end
                                ns_cnt  <= ns_cnt + 5'd1;
                            end
                            5'd8:begin                      // t_DSW            begin
                                LCD_DATA[7] <= 1'b0;
                                LCD_DATA[6] <= 1'b0;
                                LCD_DATA[5] <= 1'b1;
                                LCD_DATA[4] <= 1'b1;
                                LCD_DATA[3] <= 1'b0;
                                LCD_DATA[2] <= 1'b0;
                                LCD_DATA[1] <= 1'b0;
                                LCD_DATA[0] <= 1'b0;  
                                ns_cnt <= ns_cnt + 5'd1;
                            end
                            5'd16:begin                     // t_AH             begin
                                LCD_EN <= 1'b0;             // PW_EH            end
                                ns_cnt <= ns_cnt + 5'd1;    // t_DSW            end
                            end
                            5'd18:begin                     // t_AH             end
                                LCD_RS          <= 1'b1;
                                ns_cnt <= ns_cnt + 5'd1;
                            end
                            5'd30:begin                    // t_cycle           end
                                ns_cnt <= ns_cnt;
                            end
                            default:begin
                                ns_cnt <= ns_cnt + 5'd1;
                            end
                        endcase
                    end
                    8'h1a:begin                            
                        case(ns_cnt)       
                            5'd0:begin                      // t_AS             begin
                                LCD_RS  <= 1'b0;
                                LCD_EN  <= 1'b0;
                                ns_cnt  <= ns_cnt + 5'd1;
                            end
                            5'd3:begin                      // PW_EH,t_cycle    begin
                                LCD_EN  <= 1'b1;            // t_AS             end
                                ns_cnt  <= ns_cnt + 5'd1;
                            end
                            5'd8:begin                      // t_DSW            begin
                                LCD_DATA[7] <= 1'b0;
                                LCD_DATA[6] <= 1'b0;
                                LCD_DATA[5] <= 1'b1;
                                LCD_DATA[4] <= 1'b1;
                                LCD_DATA[3] <= 1'b0;
                                LCD_DATA[2] <= 1'b0;
                                LCD_DATA[1] <= 1'b0;
                                LCD_DATA[0] <= 1'b0;  
                                ns_cnt <= ns_cnt + 5'd1;
                            end
                            5'd16:begin                     // t_AH             begin
                                LCD_EN <= 1'b0;             // PW_EH            end
                                ns_cnt <= ns_cnt + 5'd1;
                            end
                            5'd18:begin                     // t_AH             end
                                LCD_RS          <= 1'b1;
                                ns_cnt <= ns_cnt + 5'd1;
                            end
                            5'd30:begin                    // t_cycle           end
                                ns_cnt <= ns_cnt;
                            end
                            default:begin
                                ns_cnt <= ns_cnt + 5'd1;
                            end
                        endcase
                    end
                    8'h1c:begin
                        case(ns_cnt)                        
                            5'd0:begin                      // t_AS             begin
                                LCD_RS  <= 1'b0;
                                LCD_EN  <= 1'b0;
                                ns_cnt  <= ns_cnt + 5'd1;
                            end
                            5'd3:begin                      // PW_EH,t_cycle    begin
                                LCD_EN  <= 1'b1;            // t_AS             end
                                ns_cnt  <= ns_cnt + 5'd1;
                            end
                            5'd8:begin                      // t_DSW            begin
                                LCD_DATA[7] <= 1'b0;
                                LCD_DATA[6] <= 1'b0;
                                LCD_DATA[5] <= 1'b1;
                                LCD_DATA[4] <= 1'b1;
                                LCD_DATA[3] <= 1'b0;
                                LCD_DATA[2] <= 1'b0;
                                LCD_DATA[1] <= 1'b0;
                                LCD_DATA[0] <= 1'b0;  
                                ns_cnt <= ns_cnt + 5'd1;
                            end
                            5'd16:begin                     // t_AH             begin
                                LCD_EN <= 1'b0;             // PW_EH            end
                                ns_cnt <= ns_cnt + 5'd1;
                            end
                            5'd18:begin                     // t_AH             end
                                LCD_RS          <= 1'b1;
                                ns_cnt <= ns_cnt + 5'd1;
                            end
                            5'd30:begin                    // t_cycle           end
                                ns_cnt <= ns_cnt;
                            end
                            default:begin
                                ns_cnt <= ns_cnt + 5'd1;
                            end
                        endcase
                    end
                    8'h1e:begin
                       case(ns_cnt)                        
                            5'd0:begin                     // t_AS             begin
                                LCD_RS  <= 1'b0;
                                LCD_EN  <= 1'b0;
                                ns_cnt  <= ns_cnt + 5'd1;
                            end
                            5'd3:begin                      // PW_EH,t_cycle    begin
                                LCD_EN  <= 1'b1;            // t_AS             end
                                ns_cnt  <= ns_cnt + 5'd1;
                            end
                            5'd8:begin                      // t_DSW            begin
                                LCD_DATA[7] <= 1'b0;
                                LCD_DATA[6] <= 1'b0;
                                LCD_DATA[5] <= 1'b1;
                                LCD_DATA[4] <= 1'b1;
                                LCD_DATA[3] <= 1'b1;
                                LCD_DATA[2] <= 1'b0;
                                LCD_DATA[1] <= 1'b0;
                                LCD_DATA[0] <= 1'b0;  
                                ns_cnt <= ns_cnt + 5'd1;
                            end
                            5'd16:begin                     // t_AH             begin
                                LCD_EN <= 1'b0;             // PW_EH            end
                                ns_cnt <= ns_cnt + 5'd1;
                            end
                            5'd18:begin                     // t_AH             end
                                LCD_RS          <= 1'b1;
                                ns_cnt <= ns_cnt + 5'd1;
                            end
                            5'd30:begin                    // t_cycle           end
                                ns_cnt <= ns_cnt;
                            end
                            default:begin
                                ns_cnt <= ns_cnt + 5'd1;
                            end
                        endcase     
                    end
                    8'h20:begin
                        case(ns_cnt)                        
                            5'd0:begin                      // t_AS             begin
                                LCD_RS  <= 1'b0;
                                LCD_EN  <= 1'b0;
                                ns_cnt  <= ns_cnt + 5'd1;
                            end
                            5'd3:begin                      // PW_EH    begin
                                LCD_EN  <= 1'b1;            // t_AS       end
                                ns_cnt  <= ns_cnt + 5'd1;   // t_cycle    begin
                            end
                            5'd8:begin                      // t_DSW   begin
                                LCD_DATA[7] <= 1'b0;
                                LCD_DATA[6] <= 1'b0;
                                LCD_DATA[5] <= 1'b0;
                                LCD_DATA[4] <= 1'b0;
                                LCD_DATA[3] <= 1'b1;
                                LCD_DATA[2] <= 1'b0;
                                LCD_DATA[1] <= 1'b0;
                                LCD_DATA[0] <= 1'b0;  
                                ns_cnt <= ns_cnt + 5'd1;
                            end
                            5'd16:begin                     // t_AH     begin
                                LCD_EN <= 1'b0;             // PW_EH    end
                                ns_cnt <= ns_cnt + 5'd1;
                            end
                            5'd18:begin                     // t_AH     end
                                LCD_RS          <= 1'b1;
                                ns_cnt <= ns_cnt + 5'd1;
                            end
                            5'd30:begin                    // t_cycle   end
                                ns_cnt <= ns_cnt;
                            end
                            default:begin
                                ns_cnt <= ns_cnt + 5'd1;
                            end
                        endcase   
                    end
                    8'h22:begin
                        case(ns_cnt)                       
                            5'd0:begin                      // t_AS     begin
                                LCD_RS  <= 1'b0;
                                LCD_EN  <= 1'b0;
                                ns_cnt  <= ns_cnt + 5'd1;
                            end
                            5'd3:begin                      // PW_EH    begin
                                LCD_EN  <= 1'b1;            // t_cycle  begin
                                ns_cnt  <= ns_cnt + 5'd1;   // t_AS     end
                            end
                            5'd8:begin                      // t_DSW    begin
                                LCD_DATA[7] <= 1'b0;
                                LCD_DATA[6] <= 1'b0;
                                LCD_DATA[5] <= 1'b0;
                                LCD_DATA[4] <= 1'b0;
                                LCD_DATA[3] <= 1'b0;
                                LCD_DATA[2] <= 1'b0;
                                LCD_DATA[1] <= 1'b0;
                                LCD_DATA[0] <= 1'b1;  
                                ns_cnt <= ns_cnt + 5'd1;
                            end
                            5'd16:begin                     // t_AH     begin
                                LCD_EN <= 1'b0;             // PW_EH    end
                                ns_cnt <= ns_cnt + 5'd1;
                            end
                            5'd18:begin                     // t_AH     end
                                LCD_RS          <= 1'b1;
                                ns_cnt <= ns_cnt + 5'd1;
                            end
                            5'd30:begin                     // t_cycle  end       
                                ns_cnt <= ns_cnt;
                            end
                            default:begin
                                ns_cnt <= ns_cnt + 5'd1;
                            end
                        endcase   
                    end
                    8'h24:begin
                        case(ns_cnt)                       
                            5'd0:begin                      // t_AS     begin
                                LCD_RS  <= 1'b0;
                                LCD_EN  <= 1'b0;
                                ns_cnt  <= ns_cnt + 5'd1;
                            end
                            5'd3:begin                      // PW_EH    begin
                                LCD_EN  <= 1'b1;            // t_cycle  begin
                                ns_cnt  <= ns_cnt + 5'd1;   // t_AS     end
                            end
                            5'd8:begin                      // t_DSW    begin
                                LCD_DATA[7] <= 1'b0;
                                LCD_DATA[6] <= 1'b0;
                                LCD_DATA[5] <= 1'b0;
                                LCD_DATA[4] <= 1'b0;
                                LCD_DATA[3] <= 1'b0;
                                LCD_DATA[2] <= 1'b1;
                                LCD_DATA[1] <= 1'b1;
                                LCD_DATA[0] <= 1'b0;  
                                ns_cnt <= ns_cnt + 5'd1;
                            end
                            5'd16:begin                     // t_AH     begin
                                LCD_EN <= 1'b0;             // PW_EH    end
                                ns_cnt <= ns_cnt + 5'd1;
                            end
                            5'd18:begin                     // t_AH     end
                                LCD_RS          <= 1'b1;
                                ns_cnt <= ns_cnt + 5'd1;
                            end
                            5'd30:begin                     // t_cycle  end       
                                ns_cnt <= ns_cnt;
                            end
                            default:begin
                                ns_cnt <= ns_cnt + 5'd1;
                            end
                        endcase   
                    end
                    default:begin
                        ns_cnt <= 5'd0;
                    end
                endcase    
            end
            1'b1:begin   
                case(ms_cnt)
                    8'h00:begin     //display on
                        case(ns_cnt)                       
                            5'd0:begin                      // t_AS     begin
                                LCD_RS  <= 1'b0;
                                LCD_EN  <= 1'b0;
                                ns_cnt  <= ns_cnt + 5'd1;
                            end
                            5'd3:begin                      // PW_EH    begin
                                LCD_EN  <= 1'b1;            // t_cycle  begin
                                ns_cnt  <= ns_cnt + 5'd1;   // t_AS     end
                            end
                            5'd8:begin                      // t_DSW    begin
                                LCD_DATA[7] <= 1'b0;
                                LCD_DATA[6] <= 1'b0;
                                LCD_DATA[5] <= 1'b0;
                                LCD_DATA[4] <= 1'b0;
                                LCD_DATA[3] <= 1'b1;
                                LCD_DATA[2] <= 1'b1;
                                LCD_DATA[1] <= 1'b0;
                                LCD_DATA[0] <= 1'b0;  
                                ns_cnt <= ns_cnt + 5'd1;
                            end
                            5'd16:begin                     // t_AH     begin
                                LCD_EN <= 1'b0;             // PW_EH    end
                                ns_cnt <= ns_cnt + 5'd1;
                            end
                            5'd18:begin                     // t_AH     end
                                LCD_RS          <= 1'b1;
                                ns_cnt <= ns_cnt + 5'd1;
                            end
                            5'd30:begin                     // t_cycle  end       
                                ns_cnt <= ns_cnt;
                            end
                            default:begin
                                ns_cnt <= ns_cnt + 5'd1;
                            end
                        endcase
                    end
                    8'h02:begin     //set ddram address 0x03
                        case(ns_cnt)                       
                            5'd0:begin                      // t_AS     begin
                                LCD_RS  <= 1'b0;
                                LCD_EN  <= 1'b0;
                                ns_cnt  <= ns_cnt + 5'd1;
                            end
                            5'd3:begin                      // PW_EH    begin
                                LCD_EN  <= 1'b1;            // t_cycle  begin
                                ns_cnt  <= ns_cnt + 5'd1;   // t_AS     end
                            end
                            5'd8:begin                      // t_DSW    begin
                                LCD_DATA[7] <= 1'b1;
                                LCD_DATA[6] <= 1'b0;
                                LCD_DATA[5] <= 1'b0;
                                LCD_DATA[4] <= 1'b0;
                                LCD_DATA[3] <= 1'b0;
                                LCD_DATA[2] <= 1'b0;
                                LCD_DATA[1] <= 1'b1;
                                LCD_DATA[0] <= 1'b1;  
                                ns_cnt <= ns_cnt + 5'd1;
                            end
                            5'd16:begin                     // t_AH     begin
                                LCD_EN <= 1'b0;             // PW_EH    end
                                ns_cnt <= ns_cnt + 5'd1;
                            end
                            5'd18:begin                     // t_AH     end
                                LCD_RS          <= 1'b1;
                                ns_cnt <= ns_cnt + 5'd1;
                            end
                            5'd30:begin                     // t_cycle  end       
                                ns_cnt <= ns_cnt;
                            end
                            default:begin
                                ns_cnt <= ns_cnt + 5'd1;
                            end
                        endcase
                    end
                    8'h04:begin     //write "I"
                        case(ns_cnt)                       
                            5'd0:begin                      // t_AS     begin
                                LCD_RS  <= 1'b1;
                                LCD_EN  <= 1'b0;
                                ns_cnt  <= ns_cnt + 5'd1;
                            end
                            5'd3:begin                      // PW_EH    begin
                                LCD_EN  <= 1'b1;            // t_cycle  begin
                                ns_cnt  <= ns_cnt + 5'd1;   // t_AS     end
                            end
                            5'd8:begin                      // t_DSW    begin
                                LCD_DATA <= 8'h49; 
                                ns_cnt <= ns_cnt + 5'd1;
                            end
                            5'd16:begin                     // t_AH     begin
                                LCD_EN <= 1'b0;             // PW_EH    end
                                ns_cnt <= ns_cnt + 5'd1;
                            end
                            5'd18:begin                     // t_AH     end
                                LCD_RS          <= 1'b1;
                                ns_cnt <= ns_cnt + 5'd1;
                            end
                            5'd30:begin                     // t_cycle  end       
                                ns_cnt <= ns_cnt;
                            end
                            default:begin
                                ns_cnt <= ns_cnt + 5'd1;
                            end
                        endcase
                    end
                    8'h06:begin     //write "R"
                        case(ns_cnt)                       
                            5'd0:begin                      // t_AS     begin
                                LCD_RS  <= 1'b1;
                                LCD_EN  <= 1'b0;
                                ns_cnt  <= ns_cnt + 5'd1;
                            end
                            5'd3:begin                      // PW_EH    begin
                                LCD_EN  <= 1'b1;            // t_cycle  begin
                                ns_cnt  <= ns_cnt + 5'd1;   // t_AS     end
                            end
                            5'd8:begin                      // t_DSW    begin
                                LCD_DATA <= 8'h52; 
                                ns_cnt <= ns_cnt + 5'd1;
                            end
                            5'd16:begin                     // t_AH     begin
                                LCD_EN <= 1'b0;             // PW_EH    end
                                ns_cnt <= ns_cnt + 5'd1;
                            end
                            5'd18:begin                     // t_AH     end
                                LCD_RS          <= 1'b1;
                                ns_cnt <= ns_cnt + 5'd1;
                            end
                            5'd30:begin                     // t_cycle  end       
                                ns_cnt <= ns_cnt;
                            end
                            default:begin
                                ns_cnt <= ns_cnt + 5'd1;
                            end
                        endcase
                    end
                    8'h08:begin     //write " "
                        case(ns_cnt)                       
                            5'd0:begin                      // t_AS     begin
                                LCD_RS  <= 1'b1;
                                LCD_EN  <= 1'b0;
                                ns_cnt  <= ns_cnt + 5'd1;
                            end
                            5'd3:begin                      // PW_EH    begin
                                LCD_EN  <= 1'b1;            // t_cycle  begin
                                ns_cnt  <= ns_cnt + 5'd1;   // t_AS     end
                            end
                            5'd8:begin                      // t_DSW    begin
                                LCD_DATA <= 8'h20; 
                                ns_cnt <= ns_cnt + 5'd1;
                            end
                            5'd16:begin                     // t_AH     begin
                                LCD_EN <= 1'b0;             // PW_EH    end
                                ns_cnt <= ns_cnt + 5'd1;
                            end
                            5'd18:begin                     // t_AH     end
                                LCD_RS          <= 1'b1;
                                ns_cnt <= ns_cnt + 5'd1;
                            end
                            5'd30:begin                     // t_cycle  end       
                                ns_cnt <= ns_cnt;
                            end
                            default:begin
                                ns_cnt <= ns_cnt + 5'd1;
                            end
                        endcase
                    end
                    8'h0a:begin     //write "D"
                        case(ns_cnt)                       
                            5'd0:begin                      // t_AS     begin
                                LCD_RS  <= 1'b1;
                                LCD_EN  <= 1'b0;
                                ns_cnt  <= ns_cnt + 5'd1;
                            end
                            5'd3:begin                      // PW_EH    begin
                                LCD_EN  <= 1'b1;            // t_cycle  begin
                                ns_cnt  <= ns_cnt + 5'd1;   // t_AS     end
                            end
                            5'd8:begin                      // t_DSW    begin
                                LCD_DATA <= 8'h44; 
                                ns_cnt <= ns_cnt + 5'd1;
                            end
                            5'd16:begin                     // t_AH     begin
                                LCD_EN <= 1'b0;             // PW_EH    end
                                ns_cnt <= ns_cnt + 5'd1;
                            end
                            5'd18:begin                     // t_AH     end
                                LCD_RS          <= 1'b1;
                                ns_cnt <= ns_cnt + 5'd1;
                            end
                            5'd30:begin                     // t_cycle  end       
                                ns_cnt <= ns_cnt;
                            end
                            default:begin
                                ns_cnt <= ns_cnt + 5'd1;
                            end
                        endcase
                    end
                    8'h0c:begin     //write "E"
                        case(ns_cnt)                       
                            5'd0:begin                      // t_AS     begin
                                LCD_RS  <= 1'b1;
                                LCD_EN  <= 1'b0;
                                ns_cnt  <= ns_cnt + 5'd1;
                            end
                            5'd3:begin                      // PW_EH    begin
                                LCD_EN  <= 1'b1;            // t_cycle  begin
                                ns_cnt  <= ns_cnt + 5'd1;   // t_AS     end
                            end
                            5'd8:begin                      // t_DSW    begin
                                LCD_DATA <= 8'h45; 
                                ns_cnt <= ns_cnt + 5'd1;
                            end
                            5'd16:begin                     // t_AH     begin
                                LCD_EN <= 1'b0;             // PW_EH    end
                                ns_cnt <= ns_cnt + 5'd1;
                            end
                            5'd18:begin                     // t_AH     end
                                LCD_RS          <= 1'b1;
                                ns_cnt <= ns_cnt + 5'd1;
                            end
                            5'd30:begin                     // t_cycle  end       
                                ns_cnt <= ns_cnt;
                            end
                            default:begin
                                ns_cnt <= ns_cnt + 5'd1;
                            end
                        endcase
                    end
                    8'h0e:begin     //write "C"
                        case(ns_cnt)                       
                            5'd0:begin                      // t_AS     begin
                                LCD_RS  <= 1'b1;
                                LCD_EN  <= 1'b0;
                                ns_cnt  <= ns_cnt + 5'd1;
                            end
                            5'd3:begin                      // PW_EH    begin
                                LCD_EN  <= 1'b1;            // t_cycle  begin
                                ns_cnt  <= ns_cnt + 5'd1;   // t_AS     end
                            end
                            5'd8:begin                      // t_DSW    begin
                                LCD_DATA <= 8'h43;  
                                ns_cnt <= ns_cnt + 5'd1;
                            end
                            5'd16:begin                     // t_AH     begin
                                LCD_EN <= 1'b0;             // PW_EH    end
                                ns_cnt <= ns_cnt + 5'd1;
                            end
                            5'd18:begin                     // t_AH     end
                                LCD_RS          <= 1'b1;
                                ns_cnt <= ns_cnt + 5'd1;
                            end
                            5'd30:begin                     // t_cycle  end       
                                ns_cnt <= ns_cnt;
                            end
                            default:begin
                                ns_cnt <= ns_cnt + 5'd1;
                            end
                        endcase
                    end
                    8'h10:begin     //write "O"
                        case(ns_cnt)                       
                            5'd0:begin                      // t_AS     begin
                                LCD_RS  <= 1'b1;
                                LCD_EN  <= 1'b0;
                                ns_cnt  <= ns_cnt + 5'd1;
                            end
                            5'd3:begin                      // PW_EH    begin
                                LCD_EN  <= 1'b1;            // t_cycle  begin
                                ns_cnt  <= ns_cnt + 5'd1;   // t_AS     end
                            end
                            5'd8:begin                      // t_DSW    begin
                                LCD_DATA <= 8'h4F;  
                                ns_cnt <= ns_cnt + 5'd1;
                            end
                            5'd16:begin                     // t_AH     begin
                                LCD_EN <= 1'b0;             // PW_EH    end
                                ns_cnt <= ns_cnt + 5'd1;
                            end
                            5'd18:begin                     // t_AH     end
                                LCD_RS          <= 1'b1;
                                ns_cnt <= ns_cnt + 5'd1;
                            end
                            5'd30:begin                     // t_cycle  end       
                                ns_cnt <= ns_cnt;
                            end
                            default:begin
                                ns_cnt <= ns_cnt + 5'd1;
                            end
                        endcase
                    end
                    8'h12:begin     //write "D"
                        case(ns_cnt)                       
                            5'd0:begin                      // t_AS     begin
                                LCD_RS  <= 1'b1;
                                LCD_EN  <= 1'b0;
                                ns_cnt  <= ns_cnt + 5'd1;
                            end
                            5'd3:begin                      // PW_EH    begin
                                LCD_EN  <= 1'b1;            // t_cycle  begin
                                ns_cnt  <= ns_cnt + 5'd1;   // t_AS     end
                            end
                            5'd8:begin                      // t_DSW    begin
                                LCD_DATA <= 8'h44; 
                                ns_cnt <= ns_cnt + 5'd1;
                            end
                            5'd16:begin                     // t_AH     begin
                                LCD_EN <= 1'b0;             // PW_EH    end
                                ns_cnt <= ns_cnt + 5'd1;
                            end
                            5'd18:begin                     // t_AH     end
                                LCD_RS          <= 1'b1;
                                ns_cnt <= ns_cnt + 5'd1;
                            end
                            5'd30:begin                     // t_cycle  end       
                                ns_cnt <= ns_cnt;
                            end
                            default:begin
                                ns_cnt <= ns_cnt + 5'd1;
                            end
                        endcase
                    end
                    8'h14:begin     //write "E"
                        case(ns_cnt)                       
                            5'd0:begin                      // t_AS     begin
                                LCD_RS  <= 1'b1;
                                LCD_EN  <= 1'b0;
                                ns_cnt  <= ns_cnt + 5'd1;
                            end
                            5'd3:begin                      // PW_EH    begin
                                LCD_EN  <= 1'b1;            // t_cycle  begin
                                ns_cnt  <= ns_cnt + 5'd1;   // t_AS     end
                            end
                            5'd8:begin                      // t_DSW    begin
                                LCD_DATA <= 8'h45;  
                                ns_cnt <= ns_cnt + 5'd1;
                            end
                            5'd16:begin                     // t_AH     begin
                                LCD_EN <= 1'b0;             // PW_EH    end
                                ns_cnt <= ns_cnt + 5'd1;
                            end
                            5'd18:begin                     // t_AH     end
                                LCD_RS          <= 1'b1;
                                ns_cnt <= ns_cnt + 5'd1;
                            end
                            5'd30:begin                     // t_cycle  end       
                                ns_cnt <= ns_cnt;
                            end
                            default:begin
                                ns_cnt <= ns_cnt + 5'd1;
                            end
                        endcase
                    end
                    8'h16:begin     //write "R"
                        case(ns_cnt)                       
                            5'd0:begin                      // t_AS     begin
                                LCD_RS  <= 1'b1;
                                LCD_EN  <= 1'b0;
                                ns_cnt  <= ns_cnt + 5'd1;
                            end
                            5'd3:begin                      // PW_EH    begin
                                LCD_EN  <= 1'b1;            // t_cycle  begin
                                ns_cnt  <= ns_cnt + 5'd1;   // t_AS     end
                            end
                            5'd8:begin                      // t_DSW    begin
                                LCD_DATA <= 8'h52;
                                ns_cnt <= ns_cnt + 5'd1;
                            end
                            5'd16:begin                     // t_AH     begin
                                LCD_EN <= 1'b0;             // PW_EH    end
                                ns_cnt <= ns_cnt + 5'd1;
                            end
                            5'd18:begin                     // t_AH     end
                                LCD_RS          <= 1'b1;
                                ns_cnt <= ns_cnt + 5'd1;
                            end
                            5'd30:begin                     // t_cycle  end       
                                ns_cnt <= ns_cnt;
                            end
                            default:begin
                                ns_cnt <= ns_cnt + 5'd1;
                            end
                        endcase
                    end
                    8'h18:begin     //set ddram address 0x43
                        case(ns_cnt)                       
                            5'd0:begin                      // t_AS     begin
                                LCD_RS  <= 1'b0;
                                LCD_EN  <= 1'b0;
                                ns_cnt  <= ns_cnt + 5'd1;
                            end
                            5'd3:begin                      // PW_EH    begin
                                LCD_EN  <= 1'b1;            // t_cycle  begin
                                ns_cnt  <= ns_cnt + 5'd1;   // t_AS     end
                            end
                            5'd8:begin                      // t_DSW    begin
                                LCD_DATA[7] <= 1'b1;
                                LCD_DATA[6] <= 1'b1;
                                LCD_DATA[5] <= 1'b0;
                                LCD_DATA[4] <= 1'b0;
                                LCD_DATA[3] <= 1'b0;
                                LCD_DATA[2] <= 1'b0;
                                LCD_DATA[1] <= 1'b1;
                                LCD_DATA[0] <= 1'b1;  
                                ns_cnt <= ns_cnt + 5'd1;
                            end
                            5'd16:begin                     // t_AH     begin
                                LCD_EN <= 1'b0;             // PW_EH    end
                                ns_cnt <= ns_cnt + 5'd1;
                            end
                            5'd18:begin                     // t_AH     end
                                LCD_RS          <= 1'b1;
                                ns_cnt <= ns_cnt + 5'd1;
                            end
                            5'd30:begin                     // t_cycle  end       
                                ns_cnt <= ns_cnt;
                            end
                            default:begin
                                ns_cnt <= ns_cnt + 5'd1;
                            end
                        endcase
                    end
                    8'h1a:begin     // write "custom_l upper bits"
                        case(ns_cnt)                       
                            5'd0:begin                      // t_AS     begin
                                LCD_RS  <= 1'b1;
                                LCD_EN  <= 1'b0;
                                ns_cnt  <= ns_cnt + 5'd1;
                            end
                            5'd3:begin                      // PW_EH    begin
                                LCD_EN  <= 1'b1;            // t_cycle  begin
                                ns_cnt  <= ns_cnt + 5'd1;   // t_AS     end
                            end
                            5'd8:begin                      // t_DSW    begin
                                case(clu_lcm)
                                    4'h0:begin
                                        LCD_DATA <= 8'h30;
                                        ns_cnt <= ns_cnt + 5'd1;
                                    end
                                    4'h1:begin
                                        LCD_DATA <= 8'h31;
                                        ns_cnt <= ns_cnt + 5'd1;
                                    end
                                    4'h2:begin
                                        LCD_DATA <= 8'h32;
                                        ns_cnt <= ns_cnt + 5'd1;
                                    end
                                    4'h3:begin
                                        LCD_DATA <= 8'h33;
                                        ns_cnt <= ns_cnt + 5'd1;
                                    end
                                    4'h4:begin
                                        LCD_DATA <= 8'h34;
                                        ns_cnt <= ns_cnt + 5'd1;
                                    end
                                    4'h5:begin
                                        LCD_DATA <= 8'h35;
                                        ns_cnt <= ns_cnt + 5'd1;
                                    end
                                    4'h6:begin
                                        LCD_DATA <= 8'h36;
                                        ns_cnt <= ns_cnt + 5'd1;
                                    end
                                    4'h7:begin
                                        LCD_DATA <= 8'h37;
                                        ns_cnt <= ns_cnt + 5'd1;
                                    end
                                    4'h8:begin
                                        LCD_DATA <= 8'h38;
                                        ns_cnt <= ns_cnt + 5'd1;
                                    end
                                    4'h9:begin
                                        LCD_DATA <= 8'h39;
                                        ns_cnt <= ns_cnt + 5'd1;
                                    end
                                    4'ha:begin
                                        LCD_DATA <= 8'h41;
                                        ns_cnt <= ns_cnt + 5'd1;
                                    end
                                    4'hb:begin
                                        LCD_DATA <= 8'h42;
                                        ns_cnt <= ns_cnt + 5'd1;
                                    end
                                    4'hc:begin
                                        LCD_DATA <= 8'h43;
                                        ns_cnt <= ns_cnt + 5'd1;
                                    end
                                    4'hd:begin
                                        LCD_DATA <= 8'h44;
                                        ns_cnt <= ns_cnt + 5'd1;
                                    end
                                    4'he:begin
                                        LCD_DATA <= 8'h45;
                                        ns_cnt <= ns_cnt + 5'd1;
                                    end
                                    4'hf:begin
                                        LCD_DATA <= 8'h46;
                                        ns_cnt <= ns_cnt + 5'd1;
                                    end
                                    default:begin
                                        LCD_DATA <= 8'h30;
                                        ns_cnt <= ns_cnt + 5'd1;
                                    end
                                endcase
                            end
                            5'd16:begin                     // t_AH     begin
                                LCD_EN <= 1'b0;             // PW_EH    end
                                ns_cnt <= ns_cnt + 5'd1;
                            end
                            5'd18:begin                     // t_AH     end
                                LCD_RS          <= 1'b1;
                                ns_cnt <= ns_cnt + 5'd1;
                            end
                            5'd30:begin                     // t_cycle  end       
                                ns_cnt <= ns_cnt;
                            end
                            default:begin
                                ns_cnt <= ns_cnt + 5'd1;
                            end
                        endcase
                    end
                    8'h1c:begin     // write "custom_l lower bits"
                        case(ns_cnt)                       
                            5'd0:begin                      // t_AS     begin
                                LCD_RS  <= 1'b1;
                                LCD_EN  <= 1'b0;
                                ns_cnt  <= ns_cnt + 5'd1;
                            end
                            5'd3:begin                      // PW_EH    begin
                                LCD_EN  <= 1'b1;            // t_cycle  begin
                                ns_cnt  <= ns_cnt + 5'd1;   // t_AS     end
                            end
                            5'd8:begin                      // t_DSW    begin
                                case(cll_lcm)
                                    4'h0:begin
                                        LCD_DATA <= 8'h30;
                                        ns_cnt <= ns_cnt + 5'd1;
                                    end
                                    4'h1:begin
                                        LCD_DATA <= 8'h31;
                                        ns_cnt <= ns_cnt + 5'd1;
                                    end
                                    4'h2:begin
                                        LCD_DATA <= 8'h32;
                                        ns_cnt <= ns_cnt + 5'd1;
                                    end
                                    4'h3:begin
                                        LCD_DATA <= 8'h33;
                                        ns_cnt <= ns_cnt + 5'd1;
                                    end
                                    4'h4:begin
                                        LCD_DATA <= 8'h34;
                                        ns_cnt <= ns_cnt + 5'd1;
                                    end
                                    4'h5:begin
                                        LCD_DATA <= 8'h35;
                                        ns_cnt <= ns_cnt + 5'd1;
                                    end
                                    4'h6:begin
                                        LCD_DATA <= 8'h36;
                                        ns_cnt <= ns_cnt + 5'd1;
                                    end
                                    4'h7:begin
                                        LCD_DATA <= 8'h37;
                                        ns_cnt <= ns_cnt + 5'd1;
                                    end
                                    4'h8:begin
                                        LCD_DATA <= 8'h38;
                                        ns_cnt <= ns_cnt + 5'd1;
                                    end
                                    4'h9:begin
                                        LCD_DATA <= 8'h39;
                                        ns_cnt <= ns_cnt + 5'd1;
                                    end
                                    4'ha:begin
                                        LCD_DATA <= 8'h41;
                                        ns_cnt <= ns_cnt + 5'd1;
                                    end
                                    4'hb:begin
                                        LCD_DATA <= 8'h42;
                                        ns_cnt <= ns_cnt + 5'd1;
                                    end
                                    4'hc:begin
                                        LCD_DATA <= 8'h43;
                                        ns_cnt <= ns_cnt + 5'd1;
                                    end
                                    4'hd:begin
                                        LCD_DATA <= 8'h44;
                                        ns_cnt <= ns_cnt + 5'd1;
                                    end
                                    4'he:begin
                                        LCD_DATA <= 8'h45;
                                        ns_cnt <= ns_cnt + 5'd1;
                                    end
                                    4'hf:begin
                                        LCD_DATA <= 8'h46;
                                        ns_cnt <= ns_cnt + 5'd1;
                                    end
                                    default:begin
                                        LCD_DATA <= 8'h30;
                                        ns_cnt <= ns_cnt + 5'd1;
                                    end
                                endcase
                            end
                            5'd16:begin                     // t_AH     begin
                                LCD_EN <= 1'b0;             // PW_EH    end
                                ns_cnt <= ns_cnt + 5'd1;
                            end
                            5'd18:begin                     // t_AH     end
                                LCD_RS          <= 1'b1;
                                ns_cnt <= ns_cnt + 5'd1;
                            end
                            5'd30:begin                     // t_cycle  end       
                                ns_cnt <= ns_cnt;
                            end
                            default:begin
                                ns_cnt <= ns_cnt + 5'd1;
                            end
                        endcase
                    end
                    8'h1e:begin     // write "-"
                        case(ns_cnt)                       
                            5'd0:begin                      // t_AS     begin
                                LCD_RS  <= 1'b1;
                                LCD_EN  <= 1'b0;
                                ns_cnt  <= ns_cnt + 5'd1;
                            end
                            5'd3:begin                      // PW_EH    begin
                                LCD_EN  <= 1'b1;            // t_cycle  begin
                                ns_cnt  <= ns_cnt + 5'd1;   // t_AS     end
                            end
                            5'd8:begin                      // t_DSW    begin
                                LCD_DATA <= 8'h2d;
                                ns_cnt <= ns_cnt + 5'd1;
                            end
                            5'd16:begin                     // t_AH     begin
                                LCD_EN <= 1'b0;             // PW_EH    end
                                ns_cnt <= ns_cnt + 5'd1;
                            end
                            5'd18:begin                     // t_AH     end
                                LCD_RS          <= 1'b1;
                                ns_cnt <= ns_cnt + 5'd1;
                            end
                            5'd30:begin                     // t_cycle  end       
                                ns_cnt <= ns_cnt;
                            end
                            default:begin
                                ns_cnt <= ns_cnt + 5'd1;
                            end
                        endcase
                    end
                    8'h20:begin     // write "custom_r upper bits"
                        case(ns_cnt)                       
                            5'd0:begin                      // t_AS     begin
                                LCD_RS  <= 1'b1;
                                LCD_EN  <= 1'b0;
                                ns_cnt  <= ns_cnt + 5'd1;
                            end
                            5'd3:begin                      // PW_EH    begin
                                LCD_EN  <= 1'b1;            // t_cycle  begin
                                ns_cnt  <= ns_cnt + 5'd1;   // t_AS     end
                            end
                            5'd8:begin                      // t_DSW    begin
                                case(cru_lcm)
                                    4'h0:begin
                                        LCD_DATA <= 8'h30;
                                        ns_cnt <= ns_cnt + 5'd1;
                                    end
                                    4'h1:begin
                                        LCD_DATA <= 8'h31;
                                        ns_cnt <= ns_cnt + 5'd1;
                                    end
                                    4'h2:begin
                                        LCD_DATA <= 8'h32;
                                        ns_cnt <= ns_cnt + 5'd1;
                                    end
                                    4'h3:begin
                                        LCD_DATA <= 8'h33;
                                        ns_cnt <= ns_cnt + 5'd1;
                                    end
                                    4'h4:begin
                                        LCD_DATA <= 8'h34;
                                        ns_cnt <= ns_cnt + 5'd1;
                                    end
                                    4'h5:begin
                                        LCD_DATA <= 8'h35;
                                        ns_cnt <= ns_cnt + 5'd1;
                                    end
                                    4'h6:begin
                                        LCD_DATA <= 8'h36;
                                        ns_cnt <= ns_cnt + 5'd1;
                                    end
                                    4'h7:begin
                                        LCD_DATA <= 8'h37;
                                        ns_cnt <= ns_cnt + 5'd1;
                                    end
                                    4'h8:begin
                                        LCD_DATA <= 8'h38;
                                        ns_cnt <= ns_cnt + 5'd1;
                                    end
                                    4'h9:begin
                                        LCD_DATA <= 8'h39;
                                        ns_cnt <= ns_cnt + 5'd1;
                                    end
                                    4'ha:begin
                                        LCD_DATA <= 8'h41;
                                        ns_cnt <= ns_cnt + 5'd1;
                                    end
                                    4'hb:begin
                                        LCD_DATA <= 8'h42;
                                        ns_cnt <= ns_cnt + 5'd1;
                                    end
                                    4'hc:begin
                                        LCD_DATA <= 8'h43;
                                        ns_cnt <= ns_cnt + 5'd1;
                                    end
                                    4'hd:begin
                                        LCD_DATA <= 8'h44;
                                        ns_cnt <= ns_cnt + 5'd1;
                                    end
                                    4'he:begin
                                        LCD_DATA <= 8'h45;
                                        ns_cnt <= ns_cnt + 5'd1;
                                    end
                                    4'hf:begin
                                        LCD_DATA <= 8'h46;
                                        ns_cnt <= ns_cnt + 5'd1;
                                    end
                                    default:begin
                                        LCD_DATA <= 8'h30;
                                        ns_cnt <= ns_cnt + 5'd1;
                                    end
                                endcase
                            end
                            5'd16:begin                     // t_AH     begin
                                LCD_EN <= 1'b0;             // PW_EH    end
                                ns_cnt <= ns_cnt + 5'd1;
                            end
                            5'd18:begin                     // t_AH     end
                                LCD_RS          <= 1'b1;
                                ns_cnt <= ns_cnt + 5'd1;
                            end
                            5'd30:begin                     // t_cycle  end       
                                ns_cnt <= ns_cnt;
                            end
                            default:begin
                                ns_cnt <= ns_cnt + 5'd1;
                            end
                        endcase
                    end
                    8'h22:begin     // write "custom_r lower bits"
                        case(ns_cnt)                       
                            5'd0:begin                      // t_AS     begin
                                LCD_RS  <= 1'b1;
                                LCD_EN  <= 1'b0;
                                ns_cnt  <= ns_cnt + 5'd1;
                            end
                            5'd3:begin                      // PW_EH    begin
                                LCD_EN  <= 1'b1;            // t_cycle  begin
                                ns_cnt  <= ns_cnt + 5'd1;   // t_AS     end
                            end
                            5'd8:begin                      // t_DSW    begin
                                case(crl_lcm)
                                    4'h0:begin
                                        LCD_DATA <= 8'h30;
                                        ns_cnt <= ns_cnt + 5'd1;
                                    end
                                    4'h1:begin
                                        LCD_DATA <= 8'h31;
                                        ns_cnt <= ns_cnt + 5'd1;
                                    end
                                    4'h2:begin
                                        LCD_DATA <= 8'h32;
                                        ns_cnt <= ns_cnt + 5'd1;
                                    end
                                    4'h3:begin
                                        LCD_DATA <= 8'h33;
                                        ns_cnt <= ns_cnt + 5'd1;
                                    end
                                    4'h4:begin
                                        LCD_DATA <= 8'h34;
                                        ns_cnt <= ns_cnt + 5'd1;
                                    end
                                    4'h5:begin
                                        LCD_DATA <= 8'h35;
                                        ns_cnt <= ns_cnt + 5'd1;
                                    end
                                    4'h6:begin
                                        LCD_DATA <= 8'h36;
                                        ns_cnt <= ns_cnt + 5'd1;
                                    end
                                    4'h7:begin
                                        LCD_DATA <= 8'h37;
                                        ns_cnt <= ns_cnt + 5'd1;
                                    end
                                    4'h8:begin
                                        LCD_DATA <= 8'h38;
                                        ns_cnt <= ns_cnt + 5'd1;
                                    end
                                    4'h9:begin
                                        LCD_DATA <= 8'h39;
                                        ns_cnt <= ns_cnt + 5'd1;
                                    end
                                    4'ha:begin
                                        LCD_DATA <= 8'h41;
                                        ns_cnt <= ns_cnt + 5'd1;
                                    end
                                    4'hb:begin
                                        LCD_DATA <= 8'h42;
                                        ns_cnt <= ns_cnt + 5'd1;
                                    end
                                    4'hc:begin
                                        LCD_DATA <= 8'h43;
                                        ns_cnt <= ns_cnt + 5'd1;
                                    end
                                    4'hd:begin
                                        LCD_DATA <= 8'h44;
                                        ns_cnt <= ns_cnt + 5'd1;
                                    end
                                    4'he:begin
                                        LCD_DATA <= 8'h45;
                                        ns_cnt <= ns_cnt + 5'd1;
                                    end
                                    4'hf:begin
                                        LCD_DATA <= 8'h46;
                                        ns_cnt <= ns_cnt + 5'd1;
                                    end
                                    default:begin
                                        LCD_DATA <= 8'h30;
                                        ns_cnt <= ns_cnt + 5'd1;
                                    end
                                endcase
                            end
                            5'd16:begin                     // t_AH     begin
                                LCD_EN <= 1'b0;             // PW_EH    end
                                ns_cnt <= ns_cnt + 5'd1;
                            end
                            5'd18:begin                     // t_AH     end
                                LCD_RS          <= 1'b1;
                                ns_cnt <= ns_cnt + 5'd1;
                            end
                            5'd30:begin                     // t_cycle  end       
                                ns_cnt <= ns_cnt;
                            end
                            default:begin
                                ns_cnt <= ns_cnt + 5'd1;
                            end
								endcase
                    end
                    8'h24:begin     // write "-"
                        case(ns_cnt)                       
                            5'd0:begin                      // t_AS     begin
                                LCD_RS  <= 1'b1;
                                LCD_EN  <= 1'b0;
                                ns_cnt  <= ns_cnt + 5'd1;
                            end
                            5'd3:begin                      // PW_EH    begin
                                LCD_EN  <= 1'b1;            // t_cycle  begin
                                ns_cnt  <= ns_cnt + 5'd1;   // t_AS     end
                            end
                            5'd8:begin                      // t_DSW    begin
                                LCD_DATA <= 8'h2d;
                                ns_cnt <= ns_cnt + 5'd1;
                            end
                            5'd16:begin                     // t_AH     begin
                                LCD_EN <= 1'b0;             // PW_EH    end
                                ns_cnt <= ns_cnt + 5'd1;
                            end
                            5'd18:begin                     // t_AH     end
                                LCD_RS          <= 1'b1;
                                ns_cnt <= ns_cnt + 5'd1;
                            end
                            5'd30:begin                     // t_cycle  end       
                                ns_cnt <= ns_cnt;
                            end
                            default:begin
                                ns_cnt <= ns_cnt + 5'd1;
                            end
                        endcase
                    end
                    8'h26:begin     // write "key_upper"    //code here 5/13 14:21
                        case(ns_cnt)                       
                            5'd0:begin                      // t_AS     begin
                                LCD_RS  <= 1'b1;
                                LCD_EN  <= 1'b0;
                                ns_cnt  <= ns_cnt + 5'd1;
                            end
                            5'd3:begin                      // PW_EH    begin
                                LCD_EN  <= 1'b1;            // t_cycle  begin
                                ns_cnt  <= ns_cnt + 5'd1;   // t_AS     end
                            end
                            5'd8:begin                      // t_DSW    begin
                                case(ku_lcm)
                                    4'h0:begin
                                        LCD_DATA <= 8'h30;
                                        ns_cnt <= ns_cnt + 5'd1;
                                    end
                                    4'h1:begin
                                        LCD_DATA <= 8'h31;
                                        ns_cnt <= ns_cnt + 5'd1;
                                    end
                                    4'h2:begin
                                        LCD_DATA <= 8'h32;
                                        ns_cnt <= ns_cnt + 5'd1;
                                    end
                                    4'h3:begin
                                        LCD_DATA <= 8'h33;
                                        ns_cnt <= ns_cnt + 5'd1;
                                    end
                                    4'h4:begin
                                        LCD_DATA <= 8'h34;
                                        ns_cnt <= ns_cnt + 5'd1;
                                    end
                                    4'h5:begin
                                        LCD_DATA <= 8'h35;
                                        ns_cnt <= ns_cnt + 5'd1;
                                    end
                                    4'h6:begin
                                        LCD_DATA <= 8'h36;
                                        ns_cnt <= ns_cnt + 5'd1;
                                    end
                                    4'h7:begin
                                        LCD_DATA <= 8'h37;
                                        ns_cnt <= ns_cnt + 5'd1;
                                    end
                                    4'h8:begin
                                        LCD_DATA <= 8'h38;
                                        ns_cnt <= ns_cnt + 5'd1;
                                    end
                                    4'h9:begin
                                        LCD_DATA <= 8'h39;
                                        ns_cnt <= ns_cnt + 5'd1;
                                    end
                                    4'ha:begin
                                        LCD_DATA <= 8'h41;
                                        ns_cnt <= ns_cnt + 5'd1;
                                    end
                                    4'hb:begin
                                        LCD_DATA <= 8'h42;
                                        ns_cnt <= ns_cnt + 5'd1;
                                    end
                                    4'hc:begin
                                        LCD_DATA <= 8'h43;
                                        ns_cnt <= ns_cnt + 5'd1;
                                    end
                                    4'hd:begin
                                        LCD_DATA <= 8'h44;
                                        ns_cnt <= ns_cnt + 5'd1;
                                    end
                                    4'he:begin
                                        LCD_DATA <= 8'h45;
                                        ns_cnt <= ns_cnt + 5'd1;
                                    end
                                    4'hf:begin
                                        LCD_DATA <= 8'h46;
                                        ns_cnt <= ns_cnt + 5'd1;
                                    end
                                    default:begin
                                        LCD_DATA <= 8'h30;
                                        ns_cnt <= ns_cnt + 5'd1;
                                    end
                                endcase
                            end
                            5'd16:begin                     // t_AH     begin
                                LCD_EN <= 1'b0;             // PW_EH    end
                                ns_cnt <= ns_cnt + 5'd1;
                            end
                            5'd18:begin                     // t_AH     end
                                LCD_RS          <= 1'b1;
                                ns_cnt <= ns_cnt + 5'd1;
                            end
                            5'd30:begin                     // t_cycle  end       
                                ns_cnt <= ns_cnt;
                            end
                            default:begin
                                ns_cnt <= ns_cnt + 5'd1;
                            end
                        endcase
                    end
                    8'h28:begin     // write "key_lower"
                        case(ns_cnt)                       
                            5'd0:begin                      // t_AS     begin
                                LCD_RS  <= 1'b1;
                                LCD_EN  <= 1'b0;
                                ns_cnt  <= ns_cnt + 5'd1;
                            end
                            5'd3:begin                      // PW_EH    begin
                                LCD_EN  <= 1'b1;            // t_cycle  begin
                                ns_cnt  <= ns_cnt + 5'd1;   // t_AS     end
                            end
                            5'd8:begin                      // t_DSW    begin
                                case(kl_lcm)
                                    4'h0:begin
                                        LCD_DATA <= 8'h30;
                                        ns_cnt <= ns_cnt + 5'd1;
                                    end
                                    4'h1:begin
                                        LCD_DATA <= 8'h31;
                                        ns_cnt <= ns_cnt + 5'd1;
                                    end
                                    4'h2:begin
                                        LCD_DATA <= 8'h32;
                                        ns_cnt <= ns_cnt + 5'd1;
                                    end
                                    4'h3:begin
                                        LCD_DATA <= 8'h33;
                                        ns_cnt <= ns_cnt + 5'd1;
                                    end
                                    4'h4:begin
                                        LCD_DATA <= 8'h34;
                                        ns_cnt <= ns_cnt + 5'd1;
                                    end
                                    4'h5:begin
                                        LCD_DATA <= 8'h35;
                                        ns_cnt <= ns_cnt + 5'd1;
                                    end
                                    4'h6:begin
                                        LCD_DATA <= 8'h36;
                                        ns_cnt <= ns_cnt + 5'd1;
                                    end
                                    4'h7:begin
                                        LCD_DATA <= 8'h37;
                                        ns_cnt <= ns_cnt + 5'd1;
                                    end
                                    4'h8:begin
                                        LCD_DATA <= 8'h38;
                                        ns_cnt <= ns_cnt + 5'd1;
                                    end
                                    4'h9:begin
                                        LCD_DATA <= 8'h39;
                                        ns_cnt <= ns_cnt + 5'd1;
                                    end
                                    4'ha:begin
                                        LCD_DATA <= 8'h41;
                                        ns_cnt <= ns_cnt + 5'd1;
                                    end
                                    4'hb:begin
                                        LCD_DATA <= 8'h42;
                                        ns_cnt <= ns_cnt + 5'd1;
                                    end
                                    4'hc:begin
                                        LCD_DATA <= 8'h43;
                                        ns_cnt <= ns_cnt + 5'd1;
                                    end
                                    4'hd:begin
                                        LCD_DATA <= 8'h44;
                                        ns_cnt <= ns_cnt + 5'd1;
                                    end
                                    4'he:begin
                                        LCD_DATA <= 8'h45;
                                        ns_cnt <= ns_cnt + 5'd1;
                                    end
                                    4'hf:begin
                                        LCD_DATA <= 8'h46;
                                        ns_cnt <= ns_cnt + 5'd1;
                                    end
                                    default:begin
                                        LCD_DATA <= 8'h30;
                                        ns_cnt <= ns_cnt + 5'd1;
                                    end
                                endcase
                            end
                            5'd16:begin                     // t_AH     begin
                                LCD_EN <= 1'b0;             // PW_EH    end
                                ns_cnt <= ns_cnt + 5'd1;
                            end
                            5'd18:begin                     // t_AH     end
                                LCD_RS          <= 1'b1;
                                ns_cnt <= ns_cnt + 5'd1;
                            end
                            5'd30:begin                     // t_cycle  end       
                                ns_cnt <= ns_cnt;
                            end
                            default:begin
                                ns_cnt <= ns_cnt + 5'd1;
                            end
                        endcase
                    end
                    8'h2a:begin     // write "-"
                        case(ns_cnt)                       
                            5'd0:begin                      // t_AS     begin
                                LCD_RS  <= 1'b1;
                                LCD_EN  <= 1'b0;
                                ns_cnt  <= ns_cnt + 5'd1;
                            end
                            5'd3:begin                      // PW_EH    begin
                                LCD_EN  <= 1'b1;            // t_cycle  begin
                                ns_cnt  <= ns_cnt + 5'd1;   // t_AS     end
                            end
                            5'd8:begin                      // t_DSW    begin
                                LCD_DATA <= 8'h2d;
                                ns_cnt <= ns_cnt + 5'd1;
                            end
                            5'd16:begin                     // t_AH     begin
                                LCD_EN <= 1'b0;             // PW_EH    end
                                ns_cnt <= ns_cnt + 5'd1;
                            end
                            5'd18:begin                     // t_AH     end
                                LCD_RS          <= 1'b1;
                                ns_cnt <= ns_cnt + 5'd1;
                            end
                            5'd30:begin                     // t_cycle  end       
                                ns_cnt <= ns_cnt;
                            end
                            default:begin
                                ns_cnt <= ns_cnt + 5'd1;
                            end
                        endcase
                    end
                    8'h2c:begin     // write "inv_key_upper"
                        case(ns_cnt)                       
                            5'd0:begin                      // t_AS     begin
                                LCD_RS  <= 1'b1;
                                LCD_EN  <= 1'b0;
                                ns_cnt  <= ns_cnt + 5'd1;
                            end
                            5'd3:begin                      // PW_EH    begin
                                LCD_EN  <= 1'b1;            // t_cycle  begin
                                ns_cnt  <= ns_cnt + 5'd1;   // t_AS     end
                            end
                            5'd8:begin                      // t_DSW    begin
                                case(iku_lcm)
                                    4'h0:begin
                                        LCD_DATA <= 8'h30;
                                        ns_cnt <= ns_cnt + 5'd1;
                                    end
                                    4'h1:begin
                                        LCD_DATA <= 8'h31;
                                        ns_cnt <= ns_cnt + 5'd1;
                                    end
                                    4'h2:begin
                                        LCD_DATA <= 8'h32;
                                        ns_cnt <= ns_cnt + 5'd1;
                                    end
                                    4'h3:begin
                                        LCD_DATA <= 8'h33;
                                        ns_cnt <= ns_cnt + 5'd1;
                                    end
                                    4'h4:begin
                                        LCD_DATA <= 8'h34;
                                        ns_cnt <= ns_cnt + 5'd1;
                                    end
                                    4'h5:begin
                                        LCD_DATA <= 8'h35;
                                        ns_cnt <= ns_cnt + 5'd1;
                                    end
                                    4'h6:begin
                                        LCD_DATA <= 8'h36;
                                        ns_cnt <= ns_cnt + 5'd1;
                                    end
                                    4'h7:begin
                                        LCD_DATA <= 8'h37;
                                        ns_cnt <= ns_cnt + 5'd1;
                                    end
                                    4'h8:begin
                                        LCD_DATA <= 8'h38;
                                        ns_cnt <= ns_cnt + 5'd1;
                                    end
                                    4'h9:begin
                                        LCD_DATA <= 8'h39;
                                        ns_cnt <= ns_cnt + 5'd1;
                                    end
                                    4'ha:begin
                                        LCD_DATA <= 8'h41;
                                        ns_cnt <= ns_cnt + 5'd1;
                                    end
                                    4'hb:begin
                                        LCD_DATA <= 8'h42;
                                        ns_cnt <= ns_cnt + 5'd1;
                                    end
                                    4'hc:begin
                                        LCD_DATA <= 8'h43;
                                        ns_cnt <= ns_cnt + 5'd1;
                                    end
                                    4'hd:begin
                                        LCD_DATA <= 8'h44;
                                        ns_cnt <= ns_cnt + 5'd1;
                                    end
                                    4'he:begin
                                        LCD_DATA <= 8'h45;
                                        ns_cnt <= ns_cnt + 5'd1;
                                    end
                                    4'hf:begin
                                        LCD_DATA <= 8'h46;
                                        ns_cnt <= ns_cnt + 5'd1;
                                    end
                                    default:begin
                                        LCD_DATA <= 8'h30;
                                        ns_cnt <= ns_cnt + 5'd1;
                                    end
                                endcase
                            end
                            5'd16:begin                     // t_AH     begin
                                LCD_EN <= 1'b0;             // PW_EH    end
                                ns_cnt <= ns_cnt + 5'd1;
                            end
                            5'd18:begin                     // t_AH     end
                                LCD_RS          <= 1'b1;
                                ns_cnt <= ns_cnt + 5'd1;
                            end
                            5'd30:begin                     // t_cycle  end       
                                ns_cnt <= ns_cnt;
                            end
                            default:begin
                                ns_cnt <= ns_cnt + 5'd1;
                            end
                        endcase
                    end
                    8'h2e:begin     // write "inv_key_lower"
                        case(ns_cnt)                       
                            5'd0:begin                      // t_AS     begin
                                LCD_RS  <= 1'b1;
                                LCD_EN  <= 1'b0;
                                ns_cnt  <= ns_cnt + 5'd1;
                            end
                            5'd3:begin                      // PW_EH    begin
                                LCD_EN  <= 1'b1;            // t_cycle  begin
                                ns_cnt  <= ns_cnt + 5'd1;   // t_AS     end
                            end
                            5'd8:begin                      // t_DSW    begin
                                case(ikl_lcm)
                                    4'h0:begin
                                        LCD_DATA <= 8'h30;
                                        ns_cnt <= ns_cnt + 5'd1;
                                    end
                                    4'h1:begin
                                        LCD_DATA <= 8'h31;
                                        ns_cnt <= ns_cnt + 5'd1;
                                    end
                                    4'h2:begin
                                        LCD_DATA <= 8'h32;
                                        ns_cnt <= ns_cnt + 5'd1;
                                    end
                                    4'h3:begin
                                        LCD_DATA <= 8'h33;
                                        ns_cnt <= ns_cnt + 5'd1;
                                    end
                                    4'h4:begin
                                        LCD_DATA <= 8'h34;
                                        ns_cnt <= ns_cnt + 5'd1;
                                    end
                                    4'h5:begin
                                        LCD_DATA <= 8'h35;
                                        ns_cnt <= ns_cnt + 5'd1;
                                    end
                                    4'h6:begin
                                        LCD_DATA <= 8'h36;
                                        ns_cnt <= ns_cnt + 5'd1;
                                    end
                                    4'h7:begin
                                        LCD_DATA <= 8'h37;
                                        ns_cnt <= ns_cnt + 5'd1;
                                    end
                                    4'h8:begin
                                        LCD_DATA <= 8'h38;
                                        ns_cnt <= ns_cnt + 5'd1;
                                    end
                                    4'h9:begin
                                        LCD_DATA <= 8'h39;
                                        ns_cnt <= ns_cnt + 5'd1;
                                    end
                                    4'ha:begin
                                        LCD_DATA <= 8'h41;
                                        ns_cnt <= ns_cnt + 5'd1;
                                    end
                                    4'hb:begin
                                        LCD_DATA <= 8'h42;
                                        ns_cnt <= ns_cnt + 5'd1;
                                    end
                                    4'hc:begin
                                        LCD_DATA <= 8'h43;
                                        ns_cnt <= ns_cnt + 5'd1;
                                    end
                                    4'hd:begin
                                        LCD_DATA <= 8'h44;
                                        ns_cnt <= ns_cnt + 5'd1;
                                    end
                                    4'he:begin
                                        LCD_DATA <= 8'h45;
                                        ns_cnt <= ns_cnt + 5'd1;
                                    end
                                    4'hf:begin
                                        LCD_DATA <= 8'h46;
                                        ns_cnt <= ns_cnt + 5'd1;
                                    end
                                    default:begin
                                        LCD_DATA <= 8'h30;
                                        ns_cnt <= ns_cnt + 5'd1;
                                    end
                                endcase
                            end
                            5'd16:begin                     // t_AH     begin
                                LCD_EN <= 1'b0;             // PW_EH    end
                                ns_cnt <= ns_cnt + 5'd1;
                            end
                            5'd18:begin                     // t_AH     end
                                LCD_RS          <= 1'b1;
                                ns_cnt <= ns_cnt + 5'd1;
                            end
                            5'd30:begin                     // t_cycle  end       
                                ns_cnt <= ns_cnt;
                            end
                            default:begin
                                ns_cnt <= ns_cnt + 5'd1;
                            end
                        endcase
                    end
                    default:begin
                        ns_cnt <= 5'd0;
                    end
                endcase
            end
        endcase
    end
end
always @(posedge CLOCK_50 or negedge rst_n)begin
    if(!rst_n)begin
        covert_ns2ms <= 17'd0;
    end
    else begin
        if(covert_ns2ms == 17'd50_000)begin
            covert_ns2ms <= 17'd0;
        end
        else begin
            covert_ns2ms <= covert_ns2ms + 17'd1;
        end
    end
end
always @(posedge CLOCK_50 or negedge rst_n)begin
    if(!rst_n)begin
        ms_pos <= 1'b0;
    end
    else begin
        if(covert_ns2ms == 17'd50_000)begin
            ms_pos <= 1'b1;
        end
        else begin
            ms_pos <= 1'b0;
        end
    end
end
always @(posedge CLOCK_50 or negedge rst_n)begin
    if(!rst_n)begin
        init_stage  <= 1'b0;
        ms_cnt <= 5'd0;
    end
    else begin
        if(ms_pos)begin
            ms_cnt <= ms_cnt + 5'd1;
        end
        else begin
            if(init_stage)begin
                case(ms_cnt)
                    8'hff:begin
                        ms_cnt <= 8'h0;
                    end
                    default:begin
                        ms_cnt <= ms_cnt;
                    end
                endcase
            end
            else begin
                case(ms_cnt)
                    8'h26:begin
                        ms_cnt <= 8'h0;
                        init_stage  <= 1'b1;
                    end
                    default:begin
                        ms_cnt <= ms_cnt;
                    end
                endcase
            end 
        end
    end
end
always @(posedge CLOCK_50 or negedge rst_n)begin
    if(!rst_n)begin
        clear_sig <= 1'b0;
    end
    else begin
        if(ms_cnt > 8'h2e && ms_cnt < 8'hff)begin
            clear_sig <= 1'b1;
        end
        else begin
            clear_sig <= 1'b0;
        end
    end
end


endmodule 