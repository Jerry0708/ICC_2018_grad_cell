module huffman(clk, reset, gray_valid, gray_data, CNT_valid, CNT1, CNT2, CNT3, CNT4, CNT5, CNT6,
    code_valid, HC1, HC2, HC3, HC4, HC5, HC6, M1, M2, M3, M4, M5, M6);

input clk;
input reset;
input gray_valid;
input [7:0] gray_data;
output reg CNT_valid;
output reg [7:0] CNT1, CNT2, CNT3, CNT4, CNT5, CNT6;
output reg code_valid;
output reg [7:0] HC1, HC2, HC3, HC4, HC5, HC6;
output reg [7:0] M1, M2, M3, M4, M5, M6;
 
//---def param---
localparam 
	READ_PIXEL 		= 0,
	OUTPUT_CNT 		= 1,
	SET_CNTVALID 	= 2,
	BUBBLE_SORT 	= 3;
localparam
	COMB_C0			= 4,
	COMB_C1			= 5,
	COMB_C2			= 6,
	COMB_C3			= 7;
localparam
	SPLIT_C4        = 8,
	SPLIT_C3        = 9,
	SPLIT_C2        = 10,
	SPLIT_C1        = 11,
	SPLIT_C0        = 12;
localparam
	OUPUT_BUF		= 13,
	OUPUT_HC		= 14,
	END				= 15;

//---def fsm reg---
reg [3:0]cur_state;
reg [3:0]next_state;

//---def reg---
integer i;
reg [6:0]cnt_symbol;
reg [7:0]C0_temp;
reg [7:0]C1_temp;
reg [7:0]C2_temp;
reg [8:0]C3_temp;

//probability
reg [7:0]C0[1:6];
reg [7:0]C1[1:5];
reg [7:0]C2[1:4];
reg [7:0]C3[1:3];
reg [8:0]C4[1:2];
//symbol
reg [2:0]S0[1:6];
reg [2:0]S1[1:5];
reg [2:0]S2[1:4];
reg [2:0]S3[1:3];
reg [2:0]S4[1:2];
//comb wire
wire [7:0]WC0[1:6];
reg [7:0]WC1[1:5];
reg [7:0]WC2[1:4];
reg [7:0]WC3[1:3];
reg [8:0]WC4[1:2];
//comb symbol
wire [2:0]WS0[1:6];
reg [2:0]WS1[1:5];
reg [2:0]WS2[1:4];
reg [2:0]WS3[1:3];
reg [2:0]WS4[1:2];
//HC
reg H4;
reg [1:0]H3;
reg [2:0]H2;
reg [3:0]H1[1:2];
reg [4:0]H0[1:2];
//output buf
reg [7:0]HC_OUT[1:6];
reg [7:0]MASK_OUT[1:6];

//---FSM---
always@(posedge clk) begin
	if(reset)	cur_state <= 4'd0;
	else 		cur_state <= next_state;
end

//---state transfer
always@(*) begin
	case(cur_state)
		READ_PIXEL:	
		begin
			if(cnt_symbol==100 && !gray_valid)	next_state = 1;
			else								next_state = 0;
		end
		OUTPUT_CNT:		next_state = 2;	
		SET_CNTVALID:	next_state = 3;	
		BUBBLE_SORT:	next_state = 4;	
		COMB_C0:		next_state = 5;	
		COMB_C1:		next_state = 6;	
		COMB_C2:		next_state = 7;	
		COMB_C3:		next_state = 8;	
		SPLIT_C4:		next_state = 9;	
		SPLIT_C3:		next_state = 10;
		SPLIT_C2:		next_state = 11;
		SPLIT_C1:		next_state = 12;
		SPLIT_C0:		next_state = 13;
		OUPUT_BUF:		next_state = 14;
		OUPUT_HC: 		next_state = 15;
		END: 			next_state = 0;
	endcase
end

//output 
always@(posedge clk) begin
	if(reset) begin
		code_valid <= 0;	
		for(i=1; i<=3'd6; i=i+1) HC_OUT[i] <= 8'd0;
		for(i=1; i<=3'd6; i=i+1) MASK_OUT[i] <= 8'd0;
	end
	else begin
		code_valid <= 0;	
		if(cur_state==OUPUT_BUF) begin
			if(S2[3]==0 && S2[4]==0) begin
				HC_OUT[S0[1]] <= H4;
				HC_OUT[S0[2]] <= H3;
				HC_OUT[S0[3]] <= H1[1];
				HC_OUT[S0[4]] <= H1[2];
				HC_OUT[S0[5]] <= H0[1];
				HC_OUT[S0[6]] <= H0[2];
				MASK_OUT[S0[1]] <= 8'b0000_0001;
				MASK_OUT[S0[2]] <= 8'b0000_0011;
				MASK_OUT[S0[3]] <= 8'b0000_1111;
				MASK_OUT[S0[4]] <= 8'b0000_1111;
				MASK_OUT[S0[5]] <= 8'b0000_1111;
				MASK_OUT[S0[6]] <= 8'b0000_1111;
			end
			else begin
				HC_OUT[S0[1]] <= H4;
				HC_OUT[S0[2]] <= H3;
				HC_OUT[S0[3]] <= H2;
				HC_OUT[S0[4]] <= H1[1];
				HC_OUT[S0[5]] <= H0[1];
				HC_OUT[S0[6]] <= H0[2];
				MASK_OUT[S0[1]] <= 8'b0000_0001;
				MASK_OUT[S0[2]] <= 8'b0000_0011;
				MASK_OUT[S0[3]] <= 8'b0000_0111;
				MASK_OUT[S0[4]] <= 8'b0000_1111;
				MASK_OUT[S0[5]] <= 8'b0001_1111;
				MASK_OUT[S0[6]] <= 8'b0001_1111;
			end
		end
		else if(cur_state==OUPUT_HC) begin
			code_valid <= 1;
			HC1 <= HC_OUT[1];
			HC2 <= HC_OUT[2];
			HC3 <= HC_OUT[3];
			HC4 <= HC_OUT[4];
			HC5 <= HC_OUT[5];
			HC6 <= HC_OUT[6];
			
			M1 <= MASK_OUT[1];
			M2 <= MASK_OUT[2];
			M3 <= MASK_OUT[3];
			M4 <= MASK_OUT[4];
			M5 <= MASK_OUT[5];
			M6 <= MASK_OUT[6];
		end
	end
end

always@(posedge clk) begin
	if(reset) begin
		H4 <= 1'd0;
		H3 <= 2'd0;
		H2 <= 3'd0;
		H1[1] <= 4'd0;
		H1[2] <= 4'd0;
		H0[1] <= 5'd0;
		H0[2] <= 5'd0;
	end
	else begin
		case(cur_state)
			SPLIT_C4:
			begin
				if(S4[1]==0)		H4 <= 1;
				else if(S4[2]==0) 	H4 <= 0;
			end
			SPLIT_C3:
			begin
				if(S3[2]==0)		H3[1:0] <= {~H4,1'b1};
				else if(S3[3]==0)	H3[1:0] <= {~H4,1'b0};
			end
			SPLIT_C2:
			begin
				if(S2[3]==0 && S2[4]==0) begin
					H2 <= {H3[1],~H3[0],1'b1};
				end
				else if(S2[3]==0) 	H2 <= {H3[1],~H3[0],1'b1};
				else if(S2[4]==0)	H2 <= {H3[1],~H3[0],1'b0};
			end
			SPLIT_C1:
			begin
				if(S2[3]==0 && S2[4]==0) begin
					H1[1] <= {H2[2:1],~H2[0],1'b0};
					H1[2] <= {H2[2:1],~H2[0],1'b1};
				end
				else if(S1[4]==0)	H1[1] <= {H2[2:1],~H2[0],1'b1};
				else if(S1[5]==0)	H1[1] <= {H2[2:1],~H2[0],1'b0};
			end
			SPLIT_C0:
			begin
				if(S2[3]==0 && S2[4]==0) begin
					H0[1] <= {H2[2:1],H2[0],1'b0};
					H0[2] <= {H2[2:1],H2[0],1'b1};
				end
				else begin
					H0[1] <= {H1[1][3:1],~H1[1][0],1'b0};
					H0[2] <= {H1[1][3:1],~H1[1][0],1'b1};
				end
			end
		endcase
	end
end

always@(*) begin
	WC1[1] = C0[1];
	WC1[2] = C0[2];
	WC1[3] = C0[3];
	WC1[4] = C0[4];
	WC1[5] = C0[5];
	
	WS1[1] = S0[1];
	WS1[2] = S0[2];
	WS1[3] = S0[3];
	WS1[4] = S0[4];
	WS1[5] = 0;
	
	C0_temp = C0[5]+C0[6];
	
	if(C0_temp > C0[4]) begin
		if(C0_temp > C0[3]) begin
			WC1[3] = C0_temp;
			WC1[4] = C0[3];
			WC1[5] = C0[4];
			
			WS1[3] = 0;
			WS1[4] = S0[3];
			WS1[5] = S0[4];
		end
		else begin
			WC1[4] = C0_temp;
			WC1[5] = C0[4];
			
			WS1[4] = 0;
			WS1[5] = S0[4];
		end
	end
	else begin
		WC1[5] = C0_temp;
		WS1[5] = 0;
	end
end

always@(*) begin
	WC2[1] = C1[1];
	WC2[2] = C1[2];
	WC2[3] = C1[3];
	WC2[4] = C1[4];
	
	WS2[1] = S1[1];
	WS2[2] = S1[2];
	WS2[3] = S1[3];
	WS2[4] = 0;
	
	C1_temp = C1[4]+C1[5];
	
	if(C1_temp > C1[3]) begin
		if(C1_temp > C1[2]) begin
			WC2[2] = C1_temp;
			WC2[3] = C1[2];
			WC2[4] = C1[3];
			
			WS2[2] = 0;
			WS2[3] = S1[2];
			WS2[4] = S1[3];
		end
		else begin
			WC2[3] = C1_temp;
			WC2[4] = C1[3];
			
			WS2[3] = 0;
			WS2[4] = S1[3];
		end
	end
	else begin
		WC2[4] = C1_temp;
		WS2[4] = 0;
	end
end

always@(*) begin
	WC3[1] = C2[1];
	WC3[2] = C2[2];
	WC3[3] = C2[3];
	
	WS3[1] = S2[1];
	WS3[2] = S2[2];
	WS3[3] = 0;
	
	C2_temp = C2[3]+C2[4];
	
	if(C2_temp > C2[2]) begin
		if(C2_temp > C2[1]) begin
			WC3[1] = C2_temp;
			WC3[2] = C2[1];
			WC3[3] = C2[2];
			
			WS3[1] = 0;
			WS3[2] = S2[1];
			WS3[3] = S2[2];
		end
		else begin
			WC3[2] = C2_temp;
			WC3[3] = C2[2];
			
			WS3[2] = 0;
			WS3[3] = S2[2];
		end
	end
	else begin
		WC3[3] = C2_temp;
		WS3[3] = 0;
	end
end

always@(*) begin
	WC4[1] = C3[1];
	WC4[2] = C3[2];
	
	WS4[1] = S3[1];
	WS4[2] = 0;
	
	C3_temp = C3[2]+C3[3];
	
	if(C3_temp > C3[1]) begin
		WC4[1] = C3_temp;
		WC4[2] = C3[1];
		  
		WS4[1] = 0;
		WS4[2] = S3[1];
	end
	else begin
		WC4[2] = C3_temp;
		
		WS4[2] = 0;
	end
end

//combination
always@(posedge clk) begin
	if(reset) begin
		for(i=1; i<=3'd5; i=i+1) C1[i] <= 8'd0;
		for(i=1; i<=3'd4; i=i+1) C2[i] <= 8'd0;
		for(i=1; i<=3'd3; i=i+1) C3[i] <= 8'd0;
		for(i=1; i<=3'd2; i=i+1) C4[i] <= 9'd0;
		
		for(i=1; i<=3'd5; i=i+1) S1[i] <= 3'd0;
		for(i=1; i<=3'd4; i=i+1) S2[i] <= 3'd0;
		for(i=1; i<=3'd3; i=i+1) S3[i] <= 3'd0;
		for(i=1; i<=3'd2; i=i+1) S4[i] <= 3'd0;
	end
	else begin
		case(cur_state)
			COMB_C0:
			begin
				C1[1] <= WC1[1];
				C1[2] <= WC1[2];
				C1[3] <= WC1[3];
				C1[4] <= WC1[4];
				C1[5] <= WC1[5];
				S1[1] <= WS1[1];
				S1[2] <= WS1[2];
				S1[3] <= WS1[3];
				S1[4] <= WS1[4];
				S1[5] <= WS1[5];
			end
			COMB_C1:
			begin
				C2[1] <= WC2[1];
				C2[2] <= WC2[2];
				C2[3] <= WC2[3];
				C2[4] <= WC2[4];
				S2[1] <= WS2[1];
				S2[2] <= WS2[2];
				S2[3] <= WS2[3];
				S2[4] <= WS2[4];
			end
			COMB_C2:
			begin
				C3[1] <= WC3[1];
				C3[2] <= WC3[2];
				C3[3] <= WC3[3];
				S3[1] <= WS3[1];
				S3[2] <= WS3[2];
				S3[3] <= WS3[3];
			end
			COMB_C3:
			begin
				C4[1] <= WC4[1];
				C4[2] <= WC4[2];
				S4[1] <= WS4[1];
				S4[2] <= WS4[2];
			end
		endcase
	end
end

sort my_sort(
	.clk(clk),
	.in1(CNT1),
	.in2(CNT2),
	.in3(CNT3),
	.in4(CNT4),
	.in5(CNT5),
	.in6(CNT6),
	.out1(WC0[1]),
	.out2(WC0[2]),
	.out3(WC0[3]),
	.out4(WC0[4]),
	.out5(WC0[5]),
	.out6(WC0[6]),
	
	.win1(S0[1]),
	.win2(S0[2]),
	.win3(S0[3]),
	.win4(S0[4]),
	.win5(S0[5]),
	.win6(S0[6]),
	.wout1(WS0[1]),
	.wout2(WS0[2]),
	.wout3(WS0[3]),
	.wout4(WS0[4]),
	.wout5(WS0[5]),
	.wout6(WS0[6])
);


//bubble sort
always@(posedge clk) begin
	if(reset) begin
		for(i=1; i<=3'd6; i=i+1) S0[i] <= i;
	end
	else begin
		case(cur_state)
			BUBBLE_SORT:
			begin
				C0[1] <= WC0[1];
				C0[2] <= WC0[2];
				C0[3] <= WC0[3];
				C0[4] <= WC0[4];
				C0[5] <= WC0[5];
				C0[6] <= WC0[6];
				
				S0[1] <= WS0[1];
				S0[2] <= WS0[2];
				S0[3] <= WS0[3];
				S0[4] <= WS0[4];
				S0[5] <= WS0[5];
				S0[6] <= WS0[6];
			end
		endcase
	end
end
//read pixel 
always@(posedge clk) begin
	if(reset) begin
		CNT1 <= 8'd0;
		CNT2 <= 8'd0;
		CNT3 <= 8'd0;
		CNT4 <= 8'd0;
		CNT5 <= 8'd0;
		CNT6 <= 8'd0;
		cnt_symbol <= 7'd0;
		CNT_valid <= 0;
	end 
	else begin
		if(cur_state==READ_PIXEL) begin
			if(gray_valid) begin
				cnt_symbol <= cnt_symbol + 1'b1;
				case(gray_data) 
					1: CNT1 <= CNT1 + 1'b1;
					2: CNT2 <= CNT2 + 1'b1;
					3: CNT3 <= CNT3 + 1'b1;
					4: CNT4 <= CNT4 + 1'b1;
					5: CNT5 <= CNT5 + 1'b1;
					6: CNT6 <= CNT6 + 1'b1;
				endcase
			end
		end
		else if(cur_state==OUTPUT_CNT)	CNT_valid <= 1;
		else							CNT_valid <= 0;
		
	end
end

endmodule

