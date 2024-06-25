// Lab 1 : Super MOSFET Caculator (SMC)
/* In this lab, we want to design a Supper MOSFET Calculator to calculate ID and gm in a short time with given numerous 
   combinations of width, VGS 𝑎𝑛𝑑 𝑉𝐷𝑆. Furthermore, we would like to sort the result. 
	We simplify Kn = 1 / 3, Vth = 1
	Don't consider body effect and channel length modulation
	If mode[0] == 1'b1, we want the id value, else we want the gm value.
 	If mode[1] == 1'b1, we want the larger three values; otherwise, we want the smaller three values.
  	For id value: 
    		output = 3 * n0 + 4 * n1 + 5 * n2 // mode[1] == 1'b1
       		output = 3 * n3 + 4 * n4 + 5 * n5 // mode[1] == 1'b0
       		Notice that 𝑛0 is the largest one, and 𝑛5 is the smallest one. 
	 For gm value: 
    		output = n0 + n1 + n2 // mode[1] == 1'b1
       		output = n3 + n4 + n5 // mode[1] == 1'b0
       		Notice that 𝑛0 is the largest one, and 𝑛5 is the smallest one. 
*/
	
module SMC(
    // Input signals
    mode,
    W_0, V_GS_0, V_DS_0,
    W_1, V_GS_1, V_DS_1,
    W_2, V_GS_2, V_DS_2,
    W_3, V_GS_3, V_DS_3,
    W_4, V_GS_4, V_DS_4,
    W_5, V_GS_5, V_DS_5,   
    // Output signals
    out_n
);

input [2:0] W_0, V_GS_0, V_DS_0;
input [2:0] W_1, V_GS_1, V_DS_1;
input [2:0] W_2, V_GS_2, V_DS_2;
input [2:0] W_3, V_GS_3, V_DS_3;
input [2:0] W_4, V_GS_4, V_DS_4;
input [2:0] W_5, V_GS_5, V_DS_5;
input [1:0] mode;
	
output [9:0] out_n;

wire [2:0] w[0:5], Vgs[0:5], Vds[0:5];
wire [2:0] Id_T_A[0:5], Id_T_B[0:5];
wire [3:0] Id_T_C[0:5];
wire [2:0] gm_T_A[0:5], gm_T_B[0:5], gm_T_C[0:5];
wire [2:0] Id_S_A[0:5], Id_S_B[0:5], Id_S_C[0:5];
wire [2:0] gm_S_A[0:5], gm_S_B[0:5], gm_S_C[0:5];

wire is_tri[0:5];

wire [2:0] Id_A[0:5], Id_B[0:5];
wire [3:0] Id_C[0:5];
wire [2:0] gm_A[0:5], gm_B[0:5], gm_C[0:5];

wire [2:0] A[0:5], B[0:5];
wire [3:0] C[0:5];

wire [9:0] result[0:5];

wire [9:0] n[0:5], n_1[0:5];
wire [9:0]out0, out1, out2;

genvar idx;


//Turn input into array form
assign w[0] = W_0;
assign w[1] = W_1;
assign w[2] = W_2;
assign w[3] = W_3;
assign w[4] = W_4;
assign w[5] = W_5;

assign Vgs[0] = V_GS_0;
assign Vgs[1] = V_GS_1;
assign Vgs[2] = V_GS_2;
assign Vgs[3] = V_GS_3;
assign Vgs[4] = V_GS_4;
assign Vgs[5] = V_GS_5;

assign Vds[0] = V_DS_0;
assign Vds[1] = V_DS_1;
assign Vds[2] = V_DS_2;
assign Vds[3] = V_DS_3;
assign Vds[4] = V_DS_4;
assign Vds[5] = V_DS_5;

//Calaulte Id and gm
generate 
    for (idx = 0; idx <= 5; idx = idx + 1) begin : block1
        assign Id_T_A[idx] = Vds[idx];
        assign Id_T_B[idx] = w[idx];
        assign Id_T_C[idx] = 2 * (Vgs[idx] - 1) - Vds[idx];

        assign gm_T_A[idx] = 2;
        assign gm_T_B[idx] = w[idx];
        assign gm_T_C[idx] = Vds[idx];

        assign Id_S_A[idx] = w[idx];
        assign Id_S_B[idx] = Vgs[idx] - 1;
        assign Id_S_C[idx] = Vgs[idx] - 1;

        assign gm_S_A[idx] = 2;
        assign gm_S_B[idx] = w[idx];
        assign gm_S_C[idx] = Vgs[idx] - 1;
    end
endgenerate 

//Determine region for each data set
generate 
    for(idx = 0; idx <= 5; idx = idx + 1) begin : block_2
        assign is_tri[idx] = (Vgs[idx] > (Vds[idx] + 1))? 1'b1 : 1'b0;
    end
endgenerate

//Get Id and gm 
generate 
    for(idx = 0; idx <= 5; idx = idx + 1)begin : block_3
        assign Id_A[idx] = (is_tri[idx] == 1'b1)? Id_T_A[idx] : Id_S_A[idx];
        assign Id_B[idx] = (is_tri[idx] == 1'b1)? Id_T_B[idx] : Id_S_B[idx];
        assign Id_C[idx] = (is_tri[idx] == 1'b1)? Id_T_C[idx] : Id_S_C[idx];

        assign gm_A[idx] = (is_tri[idx] == 1'b1)? gm_T_A[idx] : gm_S_A[idx];
        assign gm_B[idx] = (is_tri[idx] == 1'b1)? gm_T_B[idx] : gm_S_B[idx];
        assign gm_C[idx] = (is_tri[idx] == 1'b1)? gm_T_C[idx] : gm_S_C[idx];
    end
endgenerate

//Determine Id or gm by mode[0]
generate 
    for (idx = 0; idx <= 5; idx = idx + 1) begin: block_4
        assign A[idx] = (mode[0] == 1'b1)? Id_A[idx] : gm_A[idx];
        assign B[idx] = (mode[0] == 1'b1)? Id_B[idx] : gm_B[idx];
        assign C[idx] = (mode[0] == 1'b1)? Id_C[idx] : gm_C[idx];
    end
endgenerate 

//Calaulte the output for each data 
generate 
    for (idx = 0; idx <= 5; idx = idx + 1) begin: block_5
        assign result[idx] = (A[idx] * B[idx] * C[idx]) / 3;
    end
endgenerate 

//Sort
sort sort1 (.in0(result[0]), .in1(result[1]), .in2(result[2]), 
            .in3(result[3]), .in4(result[4]), .in5(result[5]), 
            .out0(n[0]), .out1(n[1]), .out2(n[2]), 
            .out3(n[3]), .out4(n[4]), .out5(n[5]));

//Choose larger/smaller value
assign n_1[2] = (mode[1] == 1'b1)? n[2] : n[5];
assign n_1[1] = (mode[1] == 1'b1)? n[1] : n[4];
assign n_1[0] = (mode[1] == 1'b1)? n[0] : n[3];

//Baes on mode[0], choose output function 
assign out0 = (mode[0] == 1'b0)? n_1[0] : (3 * n_1[0]);
assign out1 = (mode[0] == 1'b0)? n_1[1] : (4 * n_1[1]);
assign out2 = (mode[0] == 1'b0)? n_1[2] : (5 * n_1[2]);

// Caculate the final output
assign out_n = out1 + out2 + out0;

endmodule 


//Sub module: Bubble Sort
module sort (in0, in1, in2, in3, in4, in5,
	     out0, out1, out2, out3, out4, out5
  	    );

input  wire [9:0] in0, in1, in2, in3, in4, in5;
output reg  [9:0] out0, out1, out2, out3, out4, out5;
	
integer i, j;
reg [9:0] temp;
reg [9:0] array [0:5];
	
//Transfer input into array form
always @(*)begin
	array[0] = in0;
	array[1] = in1;
	array[2] = in2;
	array[3] = in3;
	array[4] = in4;
	array[5] = in5;
//Bubble Sort	    
for (i = 0; i < 6; i = i + 1) begin
    for (j = 0 ; j < 5; j = j + 1) begin
        if (array[j] < array[j + 1])
        begin
            temp = array[j];
            array[j] = array[j + 1];
            array[j + 1] = temp;
    end end
end end

//Tranfser array back to the output 
always @(*)begin
	out0 = array[0];
      out1 = array[1];
      out2 = array[2];
      out3 = array[3];
      out4 = array[4];
      out5 = array[5];
end
endmodule
  
