`timescale 1ns/100ps
`ifndef DISABLE_DEFAULT_NET
`default_nettype none
`endif

`include "define_state.h"


module Milestone_1 (
	input  logic            Clock,
   input  logic            resetn,
	input  logic				start,
   input  logic   [15:0]   SRAM_read_data,
	output logic   [17:0]   SRAM_address,
	output logic   [15:0]   SRAM_write_data,
	output logic 				SRAM_we_n,
	output logic				stop
	
);
Milestone_1_state_type M1_state;


logic [15:0] y, u, v;
logic [15:0] U_data_buffer[1:0], V_data_buffer[1:0];

logic [17:0] UV_address_counter, Y_address_counter, RGB_data_counter, rows_counter;
logic UV_read_flag;

logic [7:0] red, green, blue;
logic [7:0] red_buf, green_buf, blue_buf;

logic [7:0] U_odd_data[5:0], V_odd_data[5:0];
logic [15:0] U_odd_accumulation, V_odd_accumulation; 

logic [7:0] red_clipped_data[1:0], green_clipped_data[1:0], blue_clipped_data[1:0];

logic signed [31:0] red_even_calc, green_even_calc, blue_even_calc;
logic signed [31:0] red_odd_calc, green_odd_calc, blue_odd_calc;

logic signed [31:0] mult_op_1, mult_op_2, mult_op_3;
logic signed [31:0] coefficient_1, coefficient_2, coefficient_3;
logic [31:0] multiplication_1, multiplication_2, multiplication_3;

//RGB even clipped data
assign red_clipped_data[0] = (red_even_calc[31]) ? 8'd0 : (|red_even_calc[30:24]) ? 8'd255 : red_even_calc[23:16];
assign green_clipped_data[0] = (green_even_calc[31]) ? 8'd0 : (|green_even_calc[30:24]) ? 8'd255 : green_even_calc[23:16];
assign blue_clipped_data[0] = (blue_even_calc[31]) ? 8'd0 : (|blue_even_calc[30:24]) ? 8'd255 : blue_even_calc[23:16];
//RGB odd clipped data
assign red_clipped_data[1] = (red_odd_calc[31]) ? 8'd0 : (|red_odd_calc[30:24]) ? 8'd255 : red_odd_calc[23:16];
assign green_clipped_data[1] = (green_odd_calc[31]) ? 8'd0 : (|green_odd_calc[30:24]) ? 8'd255 : green_odd_calc[23:16];
assign blue_clipped_data[1] = (blue_odd_calc[31]) ? 8'd0 : (|blue_odd_calc[30:24]) ? 8'd255 : blue_odd_calc[23:16];

assign multiplication_1 = coefficient_1 * mult_op_1;
assign multiplication_2 = coefficient_2 * mult_op_2;
assign multiplication_3 = coefficient_3 * mult_op_3;


always_ff @(posedge Clock or negedge resetn) begin
	if(~resetn) begin
		UV_read_flag <= 1'b0;
		SRAM_we_n <= 1'b1;
		U_odd_data[5] <= 16'd0;
		U_odd_data[4] <= 16'd0;
		U_odd_data[3] <= 16'd0;
		U_odd_data[2] <= 16'd0;
		U_odd_data[1] <= 16'd0;
		U_odd_data[0] <= 16'd0;
		V_odd_data[5] <= 16'd0;
		V_odd_data[4] <= 16'd0;
		V_odd_data[3] <= 16'd0;
		V_odd_data[2] <= 16'd0;
		V_odd_data[1] <= 16'd0;
		V_odd_data[0] <= 16'd0;
		U_data_buffer[1] <= 16'd0;
		V_data_buffer[1] <= 16'd0;
		U_data_buffer[0] <= 16'd0;
		V_data_buffer[0] <= 16'd0;
		U_odd_accumulation <= 16'd0;
		V_odd_accumulation <= 16'd0;
		red_even_calc <= 32'sd0;
		red_odd_calc <= 32'sd0;
		green_even_calc <= 32'sd0;
		green_odd_calc <= 32'sd0;
		blue_even_calc <= 32'sd0;
		blue_odd_calc <= 32'sd0;
		coefficient_1 <= 32'sd0;
		coefficient_2 <= 32'sd0;
		coefficient_3 <= 32'sd0;
		mult_op_1 <= 32'sd0;
		mult_op_2 <= 32'sd0;
		mult_op_3 <= 32'sd0;
		y <= 16'd0;
		u <= 16'd0;
		v <= 16'd0;
		UV_address_counter <= 18'd0;
		Y_address_counter <= 18'd0;
		RGB_data_counter <= 18'd0;
		red <= 8'd0;
		green <= 8'd0;
		blue <= 8'd0;
		red_buf  <= 8'd0;
		green_buf  <= 8'd0;
		blue_buf <= 8'd0;
		stop <= 1'b0;
		rows_counter <= 18'd0;
	end else begin
		case(M1_state)
			M1_IDLE: begin
				if(start) begin
					SRAM_address <= Y_address_counter;
					Y_address_counter <=  Y_address_counter + 18'd1; //fetch Y0Y1... first Y's
					UV_read_flag <= 1'b0;
					SRAM_we_n <= 1'b1;
					U_odd_data[5] <= 16'd0;
					U_odd_data[4] <= 16'd0;
					U_odd_data[3] <= 16'd0;
					U_odd_data[2] <= 16'd0;
					U_odd_data[1] <= 16'd0;
					U_odd_data[0] <= 16'd0;
					V_odd_data[5] <= 16'd0;
					V_odd_data[4] <= 16'd0;
					V_odd_data[3] <= 16'd0;
					V_odd_data[2] <= 16'd0;
					V_odd_data[1] <= 16'd0;
					V_odd_data[0] <= 16'd0;
					U_data_buffer[1] <= 16'd0;
					V_data_buffer[1]<= 16'd0;
					U_data_buffer[0] <= 16'd0;
					V_data_buffer[0] <= 16'd0;
					U_odd_accumulation <= 16'd0;
					V_odd_accumulation <= 16'd0;
					red_odd_calc <= 32'sd0;
					red_even_calc <= 32'sd0;
					green_odd_calc <= 32'sd0;
					green_even_calc <= 32'sd0;
					blue_odd_calc <= 32'sd0;
					blue_even_calc <= 32'sd0;
					coefficient_1 <= 32'sd0;
					coefficient_2 <= 32'sd0;
					coefficient_3 <= 32'sd0;
					mult_op_1 <= 32'sd0;
					mult_op_2 <= 32'sd0;
					mult_op_3 <= 32'sd0;
					y <= 16'd0;
					u <= 16'd0;
					v <= 16'd0;
					red <= 8'd0;
					green <= 8'd0;
					blue <= 8'd0;
					red_buf  <= 8'd0;
					green_buf  <= 8'd0;
					blue_buf <= 8'd0;
					M1_state <= S_LI0;
				end
			end
			S_LI0: begin
				SRAM_address <= UV_address_counter + U_STARTING_DATA_ADDRESS; //fetch U0U1... first U's
				M1_state <= S_LI1;
			end
			
			S_LI1: begin
				SRAM_address <= UV_address_counter + U_STARTING_DATA_ADDRESS + 18'd1; //fetch U2U3... second U's
				M1_state <= S_LI2;
			end
			
			S_LI2: begin
				SRAM_address <= UV_address_counter + V_STARTING_DATA_ADDRESS; //fetch V0V1... first V's
				coefficient_1 <= 32'sd76284; 
				mult_op_1 <= SRAM_read_data[15:8] - 32'sd16; //Y0 - 16 
				y <= SRAM_read_data;
				
				M1_state <= S_LI3;
			end
			
			S_LI3: begin
				SRAM_address <= UV_address_counter + V_STARTING_DATA_ADDRESS + 18'd1; //fetch V2V3... second V's
				UV_address_counter <= UV_address_counter + 18'd2;
				
				coefficient_1 <= 32'sd76284; 
				mult_op_1 <= y[7:0] - 32'sd16; //Y1-16
				
				//Calculation for U'1 --- 159(U0 + U1)
				coefficient_2 <= 32'sd159;
				mult_op_2 <= SRAM_read_data[15:8] + SRAM_read_data[7:0];
				
				U_odd_data[5] <= SRAM_read_data[15:8]; //U0 
				U_odd_data[4] <= SRAM_read_data[15:8]; //U0
				U_odd_data[3] <= SRAM_read_data[15:8]; //U0
				U_odd_data[2] <= SRAM_read_data[7:0];  //U1
				
				//store R0 G0 B0 Y values
				red_even_calc <= multiplication_1; 
				green_even_calc <= multiplication_1;
				blue_even_calc <= multiplication_1;
				
				M1_state <= S_LI4;
			end
			
			S_LI4: begin
				SRAM_address <= Y_address_counter;
				Y_address_counter <=  Y_address_counter + 18'd1;
				
				// Store 159(U0 + U1) in register
				U_odd_accumulation <= multiplication_2; 
				
				//G0 calculation
				coefficient_1 <= -32'sd25624; 
				mult_op_1 <= U_odd_data[3] - 32'sd128;
				
				//B0 calculation
				coefficient_2 <= 32'sd132251; 
				mult_op_2 <= U_odd_data[3] - 32'sd128;
				
				//Calculation for U'1 ------- -52(U0 + U2)
				coefficient_3 <= -32'sd52;
				mult_op_3 <= U_odd_data[4] + SRAM_read_data[15:8]; 
				
				U_odd_data[1] <= SRAM_read_data[15:8]; //U2 
				U_odd_data[0] <= SRAM_read_data[7:0];  //U3
				
				//store R1 G1 B1 Y values
				red_odd_calc <= multiplication_1; 
				green_odd_calc <= multiplication_1;
				blue_odd_calc <= multiplication_1;
				

				M1_state <= S_LI5;
			end
			
			
			S_LI5: begin
				SRAM_address <= UV_address_counter + U_STARTING_DATA_ADDRESS;
				
				// Store -52(U0 + U2) in register for accumulation
				U_odd_accumulation <= U_odd_accumulation + multiplication_3; 
				
				
				//Calculation for U'1 ------- 21(U0 + U3)
				coefficient_1 <= 32'sd21;
				mult_op_1 <= U_odd_data[5] + U_odd_data[0]; 
				
				//R0 calculation
				coefficient_2 <= 32'sd104595;
				mult_op_2 <= SRAM_read_data[15:8] - 32'sd128;
				
				//G0 calculation
				coefficient_3 <= -32'sd53281;
				mult_op_3 <= SRAM_read_data[15:8] - 32'sd128;
				
				V_odd_data[5] <= SRAM_read_data[15:8]; //V0
				V_odd_data[4] <= SRAM_read_data[15:8]; //V0
				V_odd_data[3] <= SRAM_read_data[15:8]; //V0
				V_odd_data[2] <= SRAM_read_data[7:0];  //V1
				
				//Storing RGB0 for U'0
				green_even_calc <= green_even_calc + multiplication_1;
				blue_even_calc <= blue_even_calc + multiplication_2;
				
				M1_state <= S_LI6;
			end
	
			
			S_LI6: begin
				SRAM_address <= UV_address_counter + V_STARTING_DATA_ADDRESS;
				UV_address_counter <= UV_address_counter + 18'd1;
				
				// Storing U'1 calculation
				u <= (U_odd_accumulation + multiplication_1 + 8'd128) >>> 8; 
				
				//Calcuation for G1
				coefficient_1 <= -32'sd25624;
				mult_op_1 <= ((U_odd_accumulation + multiplication_1 + 8'd128) >>> 8) - 32'sd128;
				
				//Calcuation for B1
				coefficient_2 <= 32'sd132251;
				mult_op_2 <= ((U_odd_accumulation + multiplication_1 + 8'd128) >>> 8) - 32'sd128;
				
				//Calculating V'1 159(V0 + V1)
				coefficient_3 <= 32'sd159;
				mult_op_3 <= V_odd_data[3] + V_odd_data[2];
				
				V_odd_data[1] <= SRAM_read_data[15:8]; //V2
				V_odd_data[0] <= SRAM_read_data[7:0];  //V3
				
				//Storing V'0 for R0 G0 B0
				red_even_calc <= red_even_calc + multiplication_2;
				green_even_calc <= green_even_calc + multiplication_3;
				
				M1_state <= S_LI7;
			end
			
			
			S_LI7: begin
				
				y <= SRAM_read_data;
				
				//Calcuation for R2 G2 B2 76284 * (Y2-16)
				coefficient_1 <= 32'sd76284; 
				mult_op_1 <= SRAM_read_data[15:8] - 32'sd16;
				
				//Calculation for V'1 159(V0 + V2)
				coefficient_2 <= -32'sd52;
				mult_op_2 <= V_odd_data[4] + V_odd_data[1]; 
				
				//Calculation for V'1 159(V0 + V3)
				coefficient_3 <= 32'sd21;
				mult_op_3 <= V_odd_data[5] + V_odd_data[0];
				
				V_odd_accumulation <= multiplication_3;
				
				//Storing RGB1 for U'1
				green_odd_calc <= green_odd_calc + multiplication_1;
				blue_odd_calc <= blue_odd_calc + multiplication_2;
				
				M1_state <= S_LI8;
			end
			
			
			S_LI8: begin
				
				//store U4U5 in buffer
				U_data_buffer[0] = SRAM_read_data;
				
				// Store V'1 calculation
				v <= (V_odd_accumulation + multiplication_2 + multiplication_3 + 8'd128) >>> 8; 
				
				//Calcuation for R1 
				coefficient_1 <= 32'sd104595;
				mult_op_1 <= (((V_odd_accumulation + multiplication_2 + multiplication_3 + 8'd128) >>> 8) - 32'sd128);
				
				//Calcuation for G1
				coefficient_2 <= -32'sd53281; 
				mult_op_2 <= (((V_odd_accumulation + multiplication_2 + multiplication_3 + 8'd128) >>> 8) - 32'sd128); 
				
				U_odd_data[5] <= U_odd_data[4]; //U0
				U_odd_data[4] <= U_odd_data[3]; //U0
				U_odd_data[3] <= U_odd_data[2]; //U1
				U_odd_data[2] <= U_odd_data[1]; //U2
				U_odd_data[1] <= U_odd_data[0]; //U3
				U_odd_data[0] <= SRAM_read_data[15:8]; //U4
				
				//Store Y values for R2 G2 B2
				red_even_calc <= multiplication_1;
				green_even_calc <= multiplication_1;
				blue_even_calc <= multiplication_1;
				
				//R0 G0 B0 complete
				red  <= red_clipped_data[0];
				green  <= green_clipped_data[0];
				blue <= blue_clipped_data[0];
				
				M1_state <= S_LI9;
			end
			
			S_LI9: begin
				
				//store V4V5 in buffer
				V_data_buffer[0] <= SRAM_read_data;
				
				//setting up U'3 calculation
				coefficient_1 <= 32'sd21;
				mult_op_1 <= U_odd_data[5] + U_odd_data[0];
				coefficient_2 <= 32'sd159;
				mult_op_2 <= U_odd_data[3] + U_odd_data[2];
				coefficient_3 <= -32'sd52;
				mult_op_3 <= U_odd_data[4] + U_odd_data[1]; 
				
				V_odd_data[5] <= V_odd_data[4]; //V0 
				V_odd_data[4] <= V_odd_data[3]; //V0
				V_odd_data[3] <= V_odd_data[2]; //V1
				V_odd_data[2] <= V_odd_data[1]; //V2
				V_odd_data[1] <= V_odd_data[0]; //V3
				V_odd_data[0] <= SRAM_read_data[15:8]; //V4
				
				//Store V'1 for R & G
				red_odd_calc <= red_odd_calc + multiplication_1;
				green_odd_calc <= green_odd_calc + multiplication_2;
				
				M1_state <= S_LI10;
			end
			S_LI10: begin
				SRAM_address <= RGB_data_counter + RGB_STARTING_DATA_ADDRESS;
				RGB_data_counter <= RGB_data_counter + 18'd1;
				
				//setting up V'3 calculation
				coefficient_1 <= 32'sd21;
				mult_op_1 <= V_odd_data[5] + V_odd_data[0];
				coefficient_2 <= 32'sd159; 
				mult_op_2 <= V_odd_data[3] + V_odd_data[2];
				coefficient_3 <= -32'sd52;
				mult_op_3 <= V_odd_data[4] + V_odd_data[1];
				
				//U'3 calculation
				u <= (multiplication_1 + multiplication_2 + multiplication_3 + 16'd128) >>> 8;
				
				//R1 G1 B1 complete
				red_buf  <= red_clipped_data[1];
				green_buf <= green_clipped_data[1];
				blue_buf <= blue_clipped_data[1];
				
				//write mode
				SRAM_we_n <= 1'b0;
				//write R0 G0
				SRAM_write_data <= {red,green};
				
				M1_state <= S_LI11;
			end
			
			S_LI11: begin
				SRAM_address <= RGB_data_counter + RGB_STARTING_DATA_ADDRESS;
				RGB_data_counter <= RGB_data_counter + 18'd1;
				
				
				//setting up RGB2 calculation
				coefficient_1 <= 32'sd104595;
				mult_op_1 <= V_odd_data[3] - 32'sd128;
				coefficient_2 <= -32'sd25624;
				mult_op_2 <= U_odd_data[3] - 32'sd128;
				coefficient_3 <= 32'sd132251; 
				mult_op_3 <= U_odd_data[3] - 32'sd128;
				
				//V'3 calculation
				v <= (multiplication_1 + multiplication_2 + multiplication_3 + 16'd128) >>> 8;
				
				//write B0 R1
				SRAM_write_data <= {blue,red_buf};
				
				U_odd_data[5] <= U_odd_data[4]; //U0
				U_odd_data[4] <= U_odd_data[3]; //U1
				U_odd_data[3] <= U_odd_data[2]; //U2
				U_odd_data[2] <= U_odd_data[1]; //U3
				U_odd_data[1] <= U_odd_data[0]; //U4
				U_odd_data[0] <= U_data_buffer[0][7:0]; //U5
				
				M1_state <= S_LI12;
			end
			
			S_LI12: begin
				SRAM_address <= RGB_data_counter + RGB_STARTING_DATA_ADDRESS;
				RGB_data_counter <= RGB_data_counter + 18'd1;
				
				V_odd_data[5] <= V_odd_data[4]; //V0
				V_odd_data[4] <= V_odd_data[3]; //V1
				V_odd_data[3] <= V_odd_data[2]; //V2
				V_odd_data[2] <= V_odd_data[1]; //V3
				V_odd_data[1] <= V_odd_data[0]; //V4
				V_odd_data[0] <= V_data_buffer[0][7:0]; //V5
				
				//setting up R3 and B3 calculation and final part of G2 calculation 
				coefficient_1 <= 32'sd76284;
				mult_op_1 <= y[7:0] - 32'sd16; 
				coefficient_2 <= -32'sd53281;
				mult_op_2 <= V_odd_data[3] - 32'sd128; 
				coefficient_3 <= 32'sd132251; 
				mult_op_3 <= u - 32'sd128;
				
				//R2 G2 B2 Calculation
				red_even_calc <= red_even_calc + multiplication_1; 
				green_even_calc <= green_even_calc + multiplication_2;
				blue_even_calc <= blue_even_calc + multiplication_3;
				
				//write G1B1
				SRAM_write_data <= {green_buf,blue_buf};
			
				
				M1_state <= S_LI13;
			end
			
			S_LI13: begin
				
				//read mode
				SRAM_we_n <= 1'b1;
				
				//finalizing G2
				green_even_calc <= green_even_calc + multiplication_2;
				
				//storing Y value for R3 G3 B3
				red_odd_calc <= multiplication_1;
				green_odd_calc <= multiplication_1;
				blue_odd_calc <= multiplication_1 + multiplication_3;
				
				//setting up calculation for R3 G3 B3
				coefficient_1 <= 32'sd104595;
				mult_op_1 <= v - 32'sd128;
				coefficient_2 <= -32'sd25624;
				mult_op_2 <= u - 32'sd128;
				coefficient_3 <= -32'sd53281;
				mult_op_3 <= v - 32'sd128; 
				
				
				M1_state <= S_LI14;
			end
			
			S_LI14: begin
				
				//storing calculations for R3 and G3
				red_odd_calc <= red_odd_calc + multiplication_1; 
				green_odd_calc <= green_odd_calc + multiplication_2 + multiplication_3;
				
				//R2 G2 B2 complete
				red  <= red_clipped_data[0];
				green <= green_clipped_data[0];
				blue <= blue_clipped_data[0];
				
				M1_state <= S_LI15;
			end
			
			S_LI15: begin
				SRAM_address <= RGB_data_counter + RGB_STARTING_DATA_ADDRESS; 
				RGB_data_counter <= RGB_data_counter + 18'd1;
				
				//RGB3 complete
				red_buf  <= red_clipped_data[1];
				green_buf <= green_clipped_data[1];
				blue_buf <= blue_clipped_data[1];
				
				//write mode
				SRAM_we_n <= 1'b0;
				//write R2G2
				SRAM_write_data <= {red,green};
				
				M1_state <= S_CC0;
			end

			S_CC0: begin //U0 U1 U2U3 U4 U5
				
				SRAM_we_n <= 1'b1;
				SRAM_address <= Y_address_counter;
				Y_address_counter <=  Y_address_counter + 18'd1;
				
				coefficient_1 <= 32'sd21;
				mult_op_1 <= (U_odd_data[5] + U_odd_data[0]);
				coefficient_2 <= 32'sd159;
				mult_op_2 <= (U_odd_data[3] + U_odd_data[2]); 
				coefficient_3 <= -32'sd52;
				mult_op_3 <= (U_odd_data[4] + U_odd_data[1]);
				
				green_buf <= green_clipped_data[1];
				
				M1_state <= S_CC1;
			end
			
			S_CC1: begin //V0 V1 V2V3 V4 V5
				
				SRAM_address <= RGB_data_counter + RGB_STARTING_DATA_ADDRESS; 
				RGB_data_counter <= RGB_data_counter + 18'd1;
				
				SRAM_we_n <= 1'b0;
				SRAM_write_data <= {blue,red_buf}; //BeRo
				
				u <= (multiplication_1 + multiplication_2 + multiplication_3 + 16'd128) >>> 8; //U'
				
				coefficient_1 <= 32'sd21;
				mult_op_1 <= (V_odd_data[5] + V_odd_data[0]);
				coefficient_2 <= 32'sd159;
				mult_op_2 <= (V_odd_data[3] + V_odd_data[2]); 
				coefficient_3 <= -32'sd52;
				mult_op_3 <= (V_odd_data[4] + V_odd_data[1]);
				
				M1_state <= S_CC2;
			end
			
			S_CC2: begin 
				SRAM_we_n <= 1'b1;
				//Read U values every other common case cycle
				if(!UV_read_flag && (Y_address_counter - rows_counter < 8'd156)) begin 
					SRAM_address <= UV_address_counter + U_STARTING_DATA_ADDRESS; //UeUo
				end
				
				v <= (multiplication_1 + multiplication_2 + multiplication_3 + 16'd128) >>> 8; //V' 
				
				coefficient_1 <= 32'sd104595;
				mult_op_1 <= V_odd_data[3] - 16'd128;
				coefficient_2 <= -32'sd25624;
				mult_op_2 <= U_odd_data[3] - 16'd128;
				coefficient_3 <= 32'sd132251;
				mult_op_3 <= U_odd_data[3] - 16'd128; 
				
				M1_state <= S_CC3;
			end
			
			S_CC3: begin 
				//Read V values every other common case cycle 
				if(!UV_read_flag && (Y_address_counter - rows_counter < 8'd156)) begin
					SRAM_address <= UV_address_counter + V_STARTING_DATA_ADDRESS;
					UV_address_counter <= UV_address_counter + 18'd1;
				end
				
				y <= SRAM_read_data;
				
				coefficient_1 <= 32'sd76284;
				mult_op_1 <= SRAM_read_data[15:8] - 16'd16; //Ye - 16
				coefficient_2 <= 32'sd76284;
				mult_op_2 <= SRAM_read_data[7:0] - 16'd16; //Yo - 16
				coefficient_3 <= -32'sd53281; 
				mult_op_3 <= V_odd_data[3] - 16'd128;
				
				red_even_calc <= multiplication_1;
				green_even_calc <= multiplication_2;
				blue_even_calc <= multiplication_3;
				
				M1_state <= S_CC4;
			end
			
			S_CC4: begin 
				SRAM_address <= RGB_data_counter + RGB_STARTING_DATA_ADDRESS; 
				RGB_data_counter <= RGB_data_counter + 18'd1;
				
				SRAM_we_n <= 1'b0;
				//write GoBo
				SRAM_write_data <= {green_buf,blue_buf}; 
				
				//setting up RGB odd calculations 
				coefficient_1 <= -32'sd25624;
				mult_op_1 <= u - 16'd128;
				coefficient_2 <= 32'sd132251;
				mult_op_2 <= u - 16'd128;
				coefficient_3 <= 32'sd104595;
				mult_op_3 <= v - 16'd128; 
				
				red_even_calc <= red_even_calc + multiplication_1;
				green_even_calc <= green_even_calc + multiplication_1 + multiplication_3;
				blue_even_calc <= blue_even_calc + multiplication_1;
				
				red_odd_calc <= multiplication_2;
				green_odd_calc <= multiplication_2;
				blue_odd_calc <= multiplication_2;
				
				
				M1_state <= S_CC5;
			end
			
			S_CC5: begin 
				
				SRAM_we_n <= 1'b1; //reading mode
				//update buffer with u values every other clock cycle 
				if(!UV_read_flag && (Y_address_counter - rows_counter < 8'd156))begin
					U_data_buffer[0] <= SRAM_read_data;
				end
				
				//shift register implementation for next cycle
				U_odd_data[5] <= U_odd_data[4]; 
				U_odd_data[4] <= U_odd_data[3];
				U_odd_data[3] <= U_odd_data[2];
				U_odd_data[2] <= U_odd_data[1];
				U_odd_data[1] <= U_odd_data[0]; 
				U_odd_data[0] <= (UV_read_flag) ? U_data_buffer[0][7:0] :  (Y_address_counter - rows_counter < 8'd156) ? SRAM_read_data[15:8] : U_data_buffer[0][7:0];
				
				coefficient_2 <= -32'sd53281;
				mult_op_2 <= v - 16'd128; 
				
				//RGB even complete
				red <= red_clipped_data[0];
				green <= green_clipped_data[0];
				blue <= blue_clipped_data[0];
				
				
				red_odd_calc <= red_odd_calc + multiplication_3;
				green_odd_calc <= green_odd_calc + multiplication_1;
				blue_odd_calc <= blue_odd_calc + multiplication_2;
				
				
				M1_state <= S_CC6;
			end
			
			S_CC6: begin 
				
				SRAM_address <= RGB_data_counter + RGB_STARTING_DATA_ADDRESS; //For CC1 or LO_1
				RGB_data_counter <= RGB_data_counter + 18'd1;
				
				if(!UV_read_flag && (Y_address_counter - rows_counter < 8'd156))begin 
					V_data_buffer[0] <= SRAM_read_data;
				end
				
				V_odd_data[5] <= V_odd_data[4]; 
				V_odd_data[4] <= V_odd_data[3];
				V_odd_data[3] <= V_odd_data[2];
				V_odd_data[2] <= V_odd_data[1];
				V_odd_data[1] <= V_odd_data[0]; 
				V_odd_data[0] <= (UV_read_flag) ? V_data_buffer[0][7:0] : (Y_address_counter - rows_counter < 8'd156) ? SRAM_read_data[15:8] : V_data_buffer[0][7:0];
				
				green_odd_calc <= green_odd_calc + multiplication_2; 
				
				//Red and Blue odd ready
				red_buf <= red_clipped_data[1];
				blue_buf <= blue_clipped_data[1];
				
				SRAM_we_n <= 1'b0;
				SRAM_write_data <= {red,green}; //write ReGe
				
				UV_read_flag <= ~UV_read_flag; //toggle the read flag for U and V
				
				if(Y_address_counter - rows_counter == 8'd157) begin 
					M1_state <= S_LO0;
				end
				else M1_state <= S_CC0;
				

			end
			

			//fetch Y values (Y314,Y315) (Y316,Y317) (Y318,Y319) in the lead out
			S_LO0: begin
				
				//Read Y values
				SRAM_we_n <= 1'b1;
				
				SRAM_address <= Y_address_counter;
				Y_address_counter <=  Y_address_counter + 18'd1;
				
				
				green_buf <= green_clipped_data[1];
				
				coefficient_1 <= 32'sd21;
				mult_op_1 <= (U_odd_data[5] + U_odd_data[0]);
				coefficient_2 <= 32'sd159; 
				mult_op_2 <= (U_odd_data[3] + U_odd_data[2]);
				coefficient_3 <= -32'sd52;
				mult_op_3 <= (U_odd_data[4] + U_odd_data[1]);
				
				M1_state <= S_LO1;
			end
			
			S_LO1: begin
				
				SRAM_address <= RGB_data_counter + RGB_STARTING_DATA_ADDRESS; 
				RGB_data_counter <= RGB_data_counter + 18'd1;
				
				u <= (multiplication_1 + multiplication_2 + multiplication_3 + 16'd128) >>> 8;
				
				coefficient_1 <= 32'sd21;
				mult_op_1 <= (V_odd_data[5] + V_odd_data[0]);
				coefficient_2 <= 32'sd159; 
				mult_op_2 <= (V_odd_data[3] + V_odd_data[2]);
				coefficient_3 <= -32'sd52;
				mult_op_3 <= (V_odd_data[4] + V_odd_data[1]);
				
				SRAM_we_n <= 1'b0;//write mode
				//Write BeRo
				SRAM_write_data <= {blue,red_buf};
				
				M1_state <= S_LO2;
			end
		
			S_LO2: begin
			
				SRAM_address <= RGB_data_counter + RGB_STARTING_DATA_ADDRESS; 
				RGB_data_counter <= RGB_data_counter + 18'd1;
				
				v <= (multiplication_1 + multiplication_2 + multiplication_3 + 16'd128) >>> 8;
				
				//Calculation for RGB even
				coefficient_1 <= 32'sd104595;
				mult_op_1 <= V_odd_data[3] - 32'sd128;
				coefficient_2 <= -32'sd25624;
				mult_op_2 <= U_odd_data[3] - 32'sd128;
				coefficient_3 <= 32'sd132251;
				mult_op_3 <= U_odd_data[3] - 32'sd128;
				
				//Write GoBo
				SRAM_write_data <= {green_buf,blue_buf};
				
				M1_state <= S_LO3;
			end

			
			S_LO3: begin
				SRAM_we_n <= 1'b1;
				y <= SRAM_read_data;
				
				//Calculation for RGB even and odd
				coefficient_1 <= 32'sd76284;
				mult_op_1 <= SRAM_read_data[15:8] - 32'sd16; //Ye - 16
				coefficient_2 <= 32'sd76284;
				mult_op_2 <= SRAM_read_data[7:0] - 32'sd16; //Yo - 16
				coefficient_3 <= -32'sd53281;
				mult_op_3 <= V_odd_data[3] - 32'sd128; //green even

				//Storing calculations done for RGB even values
				red_even_calc <= multiplication_1; 
				green_even_calc <= multiplication_2;
				blue_even_calc <= multiplication_3;
				
				M1_state <= S_LO4;
			end
			
			S_LO4: begin
				
				U_odd_data[5] <= U_odd_data[4]; 
				U_odd_data[4] <= U_odd_data[3];
				U_odd_data[3] <= U_odd_data[2];
				U_odd_data[2] <= U_odd_data[1];
				U_odd_data[1] <= U_odd_data[0]; 
				U_odd_data[0] <= U_data_buffer[0][7:0];
				
				//setting up calculation for RGB odd
				coefficient_2 <= -32'sd25624;
				mult_op_2 <= u - 32'sd128;
				coefficient_3 <= 32'sd132251;
				mult_op_3 <= u - 32'sd128;
				coefficient_1 <= 32'sd104595;
				mult_op_1 <= v - 32'sd128;
				
				//storing calculations for RGB even
				red_even_calc <= red_even_calc + multiplication_1; 
				green_even_calc <= green_even_calc + multiplication_1 + multiplication_3;
				blue_even_calc <= blue_even_calc + multiplication_1;
				
				//storing calculations for RGB odd
				red_odd_calc <= multiplication_2;
				green_odd_calc <= multiplication_2;
				blue_odd_calc <= multiplication_2;
				
			
				M1_state <= S_LO5;
			end
			
			S_LO5: begin
			
				V_odd_data[5] <= V_odd_data[4]; 
				V_odd_data[4] <= V_odd_data[3];
				V_odd_data[3] <= V_odd_data[2];
				V_odd_data[2] <= V_odd_data[1];
				V_odd_data[1] <= V_odd_data[0]; 
				V_odd_data[0] <= V_data_buffer[0][7:0];
				
				//storing calculations for RGB odd values
				red_odd_calc <= red_odd_calc + multiplication_1; 
				green_odd_calc <= green_odd_calc + multiplication_2;
				blue_odd_calc <= blue_odd_calc + multiplication_3;
				
				//RGB even complete
				red <= red_clipped_data[0];
				green <= green_clipped_data[0];
				blue <= blue_clipped_data[0];
				
				//setting up final calculation for green 
				coefficient_2 <= -32'sd53281;
				mult_op_2 <= v - 32'sd128; 
				
				M1_state <= S_LO6;
			end
			
			
			S_LO6: begin
			
				SRAM_address <= RGB_data_counter + RGB_STARTING_DATA_ADDRESS; //For CC1 or LO_1
				RGB_data_counter <= RGB_data_counter + 18'd1;
				
				//storing final green odd calculation
				green_odd_calc <= green_odd_calc + multiplication_2;
				
				//R and B odd complete
				red_buf <= red_clipped_data[1];
				blue_buf <= blue_clipped_data[1];
				
				SRAM_we_n <= 1'b0;
				//Write ReGe
				SRAM_write_data <= {red,green};
				
				
			
				if(Y_address_counter - rows_counter != 8'd160) M1_state <= S_LO0;
				else M1_state <= S_LO7;
			end
			
			
			
			S_LO7: begin
			
				SRAM_address <= RGB_data_counter + RGB_STARTING_DATA_ADDRESS; 
				RGB_data_counter <= RGB_data_counter + 18'd1;
				
				green_buf <= green_clipped_data[1];
				
				//Write BeRo
				SRAM_write_data <= {blue,red_buf};
				
				
				M1_state <= S_LO8;
			end
			
			S_LO8: begin
				SRAM_address <= RGB_data_counter + RGB_STARTING_DATA_ADDRESS; 
				RGB_data_counter <= RGB_data_counter + 18'd1;

				
				//Write GoBo
				SRAM_write_data <= {green_buf,blue_buf};
				
				
				M1_state <= S_LO9;
			end
			
			S_LO9: begin
				SRAM_we_n <= 1'b1;
				if(Y_address_counter == 18'd38400) begin
					stop <= 1'b1;
				end
				else begin
					rows_counter <= Y_address_counter;
				end
				M1_state <= M1_IDLE;
			end
	
			default: begin
				M1_state <= M1_IDLE;
			end
		
		endcase;
	end
end


endmodule 