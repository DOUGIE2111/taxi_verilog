module try (clk,a,b,c,d,e,Q,T,W);
input clk;
input a;  //按下加公里松开加时间
input d;  //切换按键
input e;
input Q;
output b; //每加一次闪烁一次
output c; //每60s闪烁一次
output  [7:0] T;
output [7:0] W;
wire [3:0] wei3,wei2,wei1,wei0,gong1,gong2,gong3,gong4,deng1,deng2;
wire [2:0] out;
wire f0;
wire [24:0] dengdai;
wire [24:0] gongli;
wire [13:0] yuan;
wire f;
wire I;
kongzhi (clk,I,Q);
ms_time(I, f);
f_500hz(clk,f0);
anjian(f,a,b,c,e,gongli,dengdai);
_3bit_plus_mc(f0,out);
_3in8out(out,W,d);
suan (clk,gongli,dengdai,yuan);
qian(yuan,dengdai,gongli,wei3,wei2,wei1,wei0,gong1,gong2,gong3,gong4,deng1,deng2);
_12345_lgt (d,deng2,deng1,wei3,wei2,wei1,wei0,gong4,gong3,gong2,gong1,out,T);        //五个灯所选则的数字0-9.
endmodule


module kongzhi (clk4,I,Q);
input  Q;
input clk4;
output reg I;
always@(clk4)
begin
    if(Q==1)
	I=0;
	else
	I=clk4;
	end
endmodule

module qian(yuan,dengdai,gongli,wei3,wei2,wei1,wei0,gong1,gong2,gong3,gong4,deng1,deng2);
input [13:0] yuan;
input [24:0] dengdai;
input [24:0] gongli;
output reg [3:0] wei3 =0;
output reg [3:0] wei2=0;
output reg [3:0] wei1=0;
output reg [3:0] wei0=0;
output reg [3:0] deng1=0;
output reg [3:0] deng2=0;
output reg [3:0] gong1=0;
output reg [3:0] gong2=0;
output reg [3:0] gong3=0;
output reg [3:0] gong4=0;
always@(yuan or dengdai)
begin
wei3 = yuan /1000%10 ;
wei2 = yuan/100%10;
wei1 = yuan/10%10;
wei0 = yuan%10;
deng2 = dengdai /10%10;
deng1 = dengdai % 10;
gong4 = gongli /1000%10;
gong3 = gongli/100%10;
gong2 = gongli/10%10;
gong1 = gongli%10;
end
endmodule

module f_500hz (clk,f0);       		//500hz的时钟脉冲
input clk;
output reg  f0;
reg [16:0] scan;
always@(posedge clk)
    begin
		if(scan==50000)
			begin 
				scan<=0;
				f0<=!f0;
			end
		else   
			scan<=scan+1;
			end
endmodule

module _3bit_plus_mc(clk1,out);  //输入为500hz的脉冲，3bit加法计数器,输出位选码。
input clk1;
output reg [2:0]out;
always@(posedge clk1)
   if(out <= 7)
   out[2:0]<=out[2:0]+1;
   else
   out<=0;
endmodule


module _3in8out (slc,bit4_output,d);       //_3bit_plus_mcz的out作为输入，控制8个数码管的com门
output reg [7:0]  bit4_output;
input[2:0] slc;
input d;
always@(slc)
begin
if(d == 1)
begin
	case(slc)
		3'b000:	bit4_output=8'b0111_1111;
		3'b001:	bit4_output=8'b1011_1111;
		3'b010:	bit4_output=8'b1101_1111;
		3'b011:	bit4_output=8'b1110_1111;
		3'b100:	bit4_output=8'b1111_0111;
		3'b101:  bit4_output=8'b1111_1011;
		3'b110:  bit4_output=8'b1111_1101;
		3'b111:  bit4_output=8'b1111_1110;
		default:	 bit4_output=8'b1111_1111;
	endcase
end
if(d == 0)
begin
	case(slc)
		3'b000:	bit4_output=8'b0111_1111;
		3'b001:	bit4_output=8'b1011_1111;
		3'b010:	bit4_output=8'b1101_1111;
		3'b011:	bit4_output=8'b1110_1111;
		3'b100:	bit4_output=8'b1111_0111;
		3'b101:  bit4_output=8'b1111_1011;
		3'b110:  bit4_output=8'b1111_1111;
		3'b111:  bit4_output=8'b1111_1111;
		default:	 bit4_output=8'b1111_1111;
	endcase
end
end
endmodule

module _12345_lgt (d,d1,d2,q1,q2,q3,q4,g1,g2,g3,g4,clk6,T);        //8+2个灯所选则的数字0-9.
input [3:0]  d1,d2,q1,q2,q3,q4,g1,g2,g3,g4;
input [2:0]  clk6;
input d;
output  reg [7:0] T;
wire [7:0] A,B,C,D,E,F,G,H,I,J;
BCD7(q1,A,clk6);
BCD7(q2,B,clk6);
BCD7(q3,C,clk6);
BCD7(q4,D,clk6);
BCD7(g1,E,clk6);
BCD7(g2,F,clk6);
BCD7(g3,G,clk6);
BCD7(g4,H,clk6);
BCD7(d1,I,clk6);
BCD7(d2,J,clk6);
always@(clk6 or d)
	begin 
	if(clk6==0)
	    T=A;
	else if (clk6==3'd1)
		T=B;
	else if (clk6==3'd2)
		T=C;
	else if (clk6==3'd3)
		T=D;
	else if (clk6==3'd4 & d == 1)
		T=E;
	else if (clk6==3'd4 & d == 0)
		T=I;
	else if (clk6==3'd5 & d == 1)
		T=F;
	else if (clk6==3'd5 & d == 0)
		T=J;
	else if (clk6==3'd6 & d == 1)
		T=G;
	else if (clk6==3'd7 & d == 1)
	   T=H ;
	end
endmodule

module BCD7(sel,out,clk6);
input [3:0]sel;
input [2:0]clk6;
output reg [7:0]out;
always@(sel)
begin 
if(clk6 == 3'd2 || clk6 == 3'd6)
	begin       
case(sel)         
		4'd0:	out=8'b0100_0000;
		4'd1:	out=8'b0111_1001;
		4'd2:	out=8'b0010_0100;
		4'd3:	out=8'b0011_0000;
		4'd4:	out=8'b0001_1001;
		4'd5:	out=8'b0001_0010;
		4'd6:	out=8'b0000_0010;
		4'd7:	out=8'b0111_1000;
		4'd8:	out=8'b0000_0000;
		4'd9:	out=8'b0001_0000;
default: out=8'b1111_1111;
endcase
end
else 
begin
case(sel)         
		4'd0:	out=8'b1100_0000;
		4'd1:	out=8'b1111_1001;
		4'd2:	out=8'b1010_0100;
		4'd3:	out=8'b1011_0000;
		4'd4:	out=8'b1001_1001;
		4'd5:	out=8'b1001_0010;
		4'd6:	out=8'b1000_0010;
		4'd7:	out=8'b1111_1000;
		4'd8:	out=8'b1000_0000;
		4'd9:	out=8'b1001_0000;
default: out=8'b1111_1111;
endcase
end
end
endmodule


module suan (clk, gongli, dengdai,yuan);
  input clk;          // 时钟输入
  input [24:0] gongli;
  input [24:0] dengdai;
  reg [24:0] gongli_at_50 = 0; // 50元时的公里数
  reg [24:0] dengdai_at = 0;   //50元时候的等待时间
 output reg [13:0] yuan = 0;       // 初始值为100
  
  always @(posedge clk) 
  begin
      if (gongli <= 30 & dengdai <= 3)    //初始的3公里和3分钟等待10元
        yuan <= 100 ;
		
		else if (gongli <= 30 & dengdai > 3)  //公里在3内，但是等待时间超过了
		  yuan <= 100 + (dengdai - 3) * 10;
		  
      else if (gongli > 30 & dengdai < 3)     //等待时间没超过，公里超过
        yuan <= 100  + (gongli - 30) * 2;
		
      else if (gongli > 30 & dengdai >= 3)    //二者都超过
        yuan <= 100  + (gongli - 30) * 2 + (dengdai - 3) * 10;
      
      // 更新 gongli_at_50
      if (yuan >= 500 & gongli > 50 & gongli_at_50 == 0)
        gongli_at_50 <= gongli;
	//更新dengdai_at的值
       if (yuan >= 500 & gongli >= 0 & gongli_at_50 == 0 & dengdai >= 43)  
		dengdai_at <= dengdai;
		
      if (yuan >= 500 & gongli > gongli_at_50 & dengdai >= 3 & dengdai > dengdai_at)   //等待超过3min
        yuan <= 500 + (gongli - gongli_at_50) * 3 + (dengdai - dengdai_at) * 10;
		
		if (yuan >= 500 & gongli >= gongli_at_50 & dengdai <= 3)  //等待没有超过3min
        yuan <= 500 + (gongli - gongli_at_50) * 3;
    end
endmodule






module anjian(clk, a, b, c,e, gongli, dengdai);
  input clk;         // 总时钟
  input a;
  input e;
  output reg b = 0;  // 按键，默认为0
  output reg c = 0;  // 按键，默认为0
  output reg [24:0] gongli = 0;
  output reg [24:0] dengdai = 0;

  reg [24:0] movecount = 0;  // 1s计算给里程数的
  reg [24:0] waitcount = 0;  // 60s的等待计数

  always @(posedge clk )
  begin
	 if(e == 0)
	 begin
	 movecount = 0;
	 gongli = 0;
	 waitcount = 0;
	 dengdai = 0;
	 end
	 else if (e == 1)
	 begin
    if (a == 0 && movecount < 25'd100)  //按下100ms进入加0.1公里，改值可以调整按下多少时间加一次公里
    begin
      movecount <= movecount + 1;
      b <= 1;
    end
    else if (movecount >= 25'd100)
    begin
      movecount <= 0;
      gongli <= gongli + 1;
      b <= 0;
    end
    if (a == 1 && waitcount < 25'd1000)  //送开进入等待时间，1s加一次。
    begin
      waitcount <= waitcount+ 1;
      c <= 1;
    end
    else if (waitcount >= 25'd1000)
    begin
      waitcount <= 0;
	   dengdai <= dengdai + 1;	
		c <= 0;
    end
  end
  end
endmodule


module ms_time(clk, f);
  input clk;
  reg [24:0] scan = 0;
  output reg f = 0;

  always @(posedge clk)
  begin
    if (scan == 24999)
    begin
      scan <= 0;
      f <= ~f;
    end
    else
      scan <= 1 + scan;
  end
endmodule

