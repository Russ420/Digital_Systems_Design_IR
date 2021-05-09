`timescale 1ns/1ns

module lab3_tb;

parameter DATA_LO_PERIOD   = 560_000; // 560us
parameter DATA0_HI_PERIOD  = 560_000; // 560us
parameter DATA1_HI_PERIOD  = 1690_000; // 560us

reg   clk_50M;
reg   reset_n;
reg   ir;
wire  LCD_RS;
wire  LCD_RW;
wire  LCD_EN;
wire  [7:0]LCD_DATA;
wire  LCD_ON;
wire  LCD_BLON;
wire  [7:0]LEDG;

lab3 u1
(
  //////// CLOCK //////////
  .CLOCK_50(clk_50M),   
  .rst_n(reset_n),
  //////// IR Receiver //////////
  .IRDA_RXD(ir),
  .LCD_RS(LCD_RS),
  .LCD_RW(LCD_RW),
  .LCD_EN(LCD_EN),
  .LCD_DATA(LCD_DATA),
  .LCD_ON(LCD_ON),
  .LCD_BLON(LCD_BLON),
  .LEDG(LEDG)
);  

always
  #10 clk_50M = ~clk_50M;
  

initial
  begin
  reset_n = 0;  
  clk_50M = 0 ;
  ir = 0;
  
  #30 reset_n = 1;
  
  // ir random noise
  #1_000_000;
  ir = 1;
  #20_000_000;
  ir = 0;
  #1_000_000;
  ir = 1;
  #3_000_000;

  // ir packet 
  send_ir_leader();  
  send_ir_byte(8'h12);   // customer code
  send_ir_byte(8'h34);   // customer code
  send_ir_byte(8'h56);   // key code
  send_ir_byte(8'hA9);   // key code reverse
  send_ir_end();       
  
  #20_000_000;
  $finish;
  end

  
task send_ir_leader;  
 begin
  ir = 0;
  #9_000_000; // 9ms Lo
  ir = 1;
  #4_500_000; // 4.5ms Hi
 end
endtask 

task send_ir_byte;
  input [7:0] byte;
  integer i;
  begin
  $display("send ir = %x ",byte);
  for (i=0; i<8; i=i+1) 
     begin 
     ir = 0;
     #(DATA_LO_PERIOD);
     ir = 1;
     if(byte[0])
       #(DATA1_HI_PERIOD);
     else
       #(DATA0_HI_PERIOD); 
     byte = byte >> 1;       
     end      
  end   
endtask 

task send_ir_end;  
 begin
  ir = 0;
  #(DATA_LO_PERIOD);  
  ir = 1;  
 end
endtask
  
endmodule
