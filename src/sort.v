module sort (
input  wire clk,

input  wire [7:0] in1, in2, in3, in4, in5, in6,
output reg  [7:0] out1, out2, out3, out4, out5, out6,

input  wire [2:0] win1, win2, win3, win4, win5, win6,
output reg  [2:0] wout1, wout2, wout3, wout4, wout5, wout6
);

reg [7:0] dat1, dat2, dat3, dat4, dat5, dat6;
reg [2:0] wdat1, wdat2, wdat3, wdat4, wdat5, wdat6;

always @(posedge clk) begin
	dat1 <= in1;
    dat2 <= in2;
    dat3 <= in3;
    dat4 <= in4;
    dat5 <= in5;
	dat6 <= in6;
	
	wdat1 <= win1;
    wdat2 <= win2;
    wdat3 <= win3;
    wdat4 <= win4;
    wdat5 <= win5;
	wdat6 <= win6;
end

integer i, j;
reg [7:0] temp;
reg [7:0] array [1:6];
reg [2:0] warray [1:6];
reg [2:0] wtemp;

always @* begin
	array[1] = dat1;
	array[2] = dat2;
	array[3] = dat3;
	array[4] = dat4;
	array[5] = dat5;
	array[6] = dat6;
	
	warray[1] = wdat1;
	warray[2] = wdat2;
	warray[3] = wdat3;
	warray[4] = wdat4;
	warray[5] = wdat5;
	warray[6] = wdat6;

	for (i = 6; i > 0; i = i - 1) begin
		for (j = 1 ; j < i; j = j + 1) begin
			if (array[j] < array[j + 1]) begin
				temp = array[j];
				array[j] = array[j + 1];
				array[j + 1] = temp;
				
				wtemp = warray[j];
				warray[j] = warray[j + 1];
				warray[j + 1] = wtemp;
			end 
		end
	end 
end

always @(posedge clk) begin
	out1 <= array[1];
	out2 <= array[2];
	out3 <= array[3];
	out4 <= array[4];
	out5 <= array[5];
	out6 <= array[6];
	
	wout1 <= warray[1];
	wout2 <= warray[2];
	wout3 <= warray[3];
	wout4 <= warray[4];
	wout5 <= warray[5];
	wout6 <= warray[6];
end

endmodule
