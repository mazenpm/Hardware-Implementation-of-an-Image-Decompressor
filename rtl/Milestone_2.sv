
`timescale 1ns/100ps
`ifndef DISABLE_DEFAULT_NET
`default_nettype none
`endif


`include "define_state.h"


module Milestone_2 (
	input  logic            Clock,
   input  logic            resetn,
	input  logic				start,
   input  logic   [15:0]   SRAM_read_data,
	output logic   [17:0]   SRAM_address,
	output logic   [15:0]   SRAM_write_data,
	output logic 				SRAM_we_n,
	output logic				stop
	
);
Milestone_2_state_type M2_state;
FS_state_type Fs_state;
CT_state_type CT_state;
CS_state_type CS_state;
WS_state_type Ws_state;


logic [15:0] FS_SRAM_write_data;
logic [15:0] WS_SRAM_write_data;

parameter Y_STARTING_DATA_ADDRESS = 18'd76800;
parameter UV_STARTING_DATA_ADDRESS = 18'd153600;


logic [17:0] FS_SRAM_address;
logic [17:0] WS_SRAM_address;

logic FS_SRAM_we_n;
logic WS_SRAM_we_n;

logic [6:0] FS_address_a, CT_address_a;
logic [6:0] CS_address_c, CT_address_c;
logic [6:0] WS_address_c;
logic [6:0] WS_address_f;
logic [6:0] WS_address_e;
logic [6:0] CS_address_e;
logic [6:0] CS_address_f;

logic [7:0] incrementor_address;

logic [17:0] Y_address_counter;
logic signed [31:0] y_buffer;

logic signed [31:0] mult_op_1;
logic signed [31:0] mult_op_2;
logic signed [31:0] mult_op_3;
logic signed [31:0] multiplication_1;
logic signed [31:0] multiplication_2;
logic signed [31:0] multiplication_3;

logic signed [31:0] CT_multiplication_1;
logic signed [31:0] CS_multiplication_1;
logic signed [31:0] CT_multiplication_2;
logic signed [31:0] CS_multiplication_2;
logic signed [31:0] CT_multiplication_3;
logic signed [31:0] CS_multiplication_3;



logic [6:0] address_a, address_b, address_c, address_d, address_e, address_f;
logic [31:0] write_data_a, write_data_b, write_data_c, write_data_d, write_data_e, write_data_f;
logic [31:0] read_data_a, read_data_b, read_data_c, read_data_d, read_data_e, read_data_f;
logic write_enable_a, write_enable_b, write_enable_c, write_enable_d, write_enable_e, write_enable_f;

logic FS_write_enable_a, CT_write_enable_a, CT_write_enable_c, CS_write_enable_c, CS_write_enable_e, WS_write_enable_e, CS_write_enable_f, WS_write_enable_f;


logic Ws_stop;
logic [18:0] sram_counter;
logic [18:0] sram_starting_address;


logic [17:0] row_data_address, column_data_address; 
logic [6:0] row_data_block, column_data_block;
logic [3:0] row_data_index, column_data_index;
logic [1:0] data_fetch_flag;
logic write_flag;
logic CT_write_flag;

logic signed [31:0] T_matrix;

logic [6:0] C_matrix_1;
logic [6:0] C_matrix_2;
logic [6:0] C_matrix_3;
logic signed [31:0] C_coeffcient_1;
logic signed [31:0] C_coeffcient_2;
logic signed [31:0] C_coeffcient_3;

logic signed [31:0] CT_C_coeffcient_1;
logic signed [31:0] CS_C_coeffcient_1;
logic signed [31:0] CT_C_coeffcient_2;
logic signed [31:0] CS_C_coeffcient_2;
logic signed [31:0] CS_C_coeffcient_3;
logic signed [31:0] CT_C_coeffcient_3;

logic signed [31:0] s3;
logic signed [31:0] s1;
logic signed [31:0] s2;
logic signed [31:0] s_buffer;
logic [7:0] S[3:1];

logic [6:0] starting_index1;
logic [6:0] starting_index2;
logic [6:0] starting_index3;

logic [6:0] c_column_counter;
logic [6:0] column_counter;
logic [31:0] row_counter;

logic FS_start, FS_stop, CT_start, CT_stop, CS_start, CS_stop, WS_start, WS_stop;

assign multiplication_1 = mult_op_1 * C_coeffcient_1;
assign multiplication_2 = mult_op_2 * C_coeffcient_2;
assign multiplication_3 = mult_op_3 * C_coeffcient_3;

assign S[3] = (s3[31]) ? 8'd0 : (|s3[30:24]) ? 8'd255 : s3[23:16]; 
assign S[2] = (s2[31]) ? 8'd0 : (|s2[30:24]) ? 8'd255 : s2[23:16]; 
assign S[1] = (s1[31]) ? 8'd0 : (|s1[30:24]) ? 8'd255 : s1[23:16];

dual_port_RAM dualport (
    .address_a(address_a),
    .address_b(address_b),
    .clock(Clock),
    .data_a(write_data_a),
    .data_b(write_data_b),
    .wren_a(write_enable_a),
    .wren_b(write_enable_b),
    .q_a(read_data_a),
    .q_b(read_data_b)
);

dual_port_RAM1 dualport1 (
    .address_a(address_c),
    .address_b(address_d),
    .clock(Clock),
    .data_a(write_data_c),
    .data_b(write_data_d),
    .wren_a(write_enable_c),
    .wren_b(write_enable_d),
    .q_a(read_data_c),
    .q_b(read_data_d)
);


dual_port_RAM2 dualport2 (
    .address_a(address_e), 
    .address_b(address_f),
    .clock(Clock),
    .data_a(write_data_e),
    .data_b(write_data_f),
    .wren_a(write_enable_e),
    .wren_b(write_enable_f),
    .q_a(read_data_e),
    .q_b(read_data_f)
);
//---------------------------------------------------Top State------------------------------//

always_ff @ (posedge Clock or negedge resetn) begin
    if (~resetn) begin
        M2_state <= M2_IDLE;
    end else begin
        if (M2_state == M2_IDLE) begin
            if (start) begin
                M2_state <= FS;
            end
        end else if (M2_state == FS) begin
            FS_start <= 1'b1;
            if (FS_stop) begin
                FS_start <= 1'b0;
                M2_state <= CT;
            end
        end else if (M2_state == CT) begin
            CT_start <= 1'b1;
            if (CT_stop) begin
                M2_state <= Mega_State_1;
                CT_start <= 1'b0;
                //$stop(1);
            end
        end else if (M2_state == Mega_State_1) begin
            CS_start <= 1'b1;
            FS_start <= 1'b1;
            if (CS_stop && FS_stop) begin
                M2_state <= Mega_State_2;
                FS_start <= 1'b0;
                CS_start <= 1'b0;
            end
        end else if (M2_state == Mega_State_2) begin
            WS_start <= 1'b1;
            CT_start <= 1'b1;
            if (WS_stop && CT_stop) begin
                M2_state <= CS;
                CT_start <= 1'b0;
                WS_start <= 1'b0;
            end
        end else if (M2_state == CS) begin
            CS_start <= 1'b1;
            if (CS_stop) begin
                M2_state <= WS;
                CS_start <= 1'b0;
            end
        end else if (M2_state == WS) begin
            WS_start <= 1'b1;
            if (WS_stop) begin
                M2_state <= M2_IDLE;
                stop <= 1'b1;
            end
        end else begin
            M2_state <= M2_IDLE;
        end
    end
end


//-----------------------------Fetch S-----------------------------------//
always @(posedge Clock or negedge resetn) begin
	if (~resetn) begin
		Fs_state <= Fs_Idle;
		FS_SRAM_we_n <= 1'b1;
		FS_SRAM_address <= 18'b0;
		FS_SRAM_write_data <= 16'b0;
		FS_stop <= 1'b0;
		y_buffer <= 32'sd0;
		FS_write_enable_a <= 1'b0;
		column_data_index <= 2'd0;
		column_data_block <= 18'b0;
		row_data_index <= 18'b0;
		row_data_block <= 18'b0;
		data_fetch_flag <= 1'b1;
		FS_address_a <= 1'b0;
		
	end else begin
		case (Fs_state)
		Fs_Idle: begin
			if (FS_start) begin
				FS_SRAM_we_n <= 1'b1;
				Fs_state <= Fs_LI0;
			end
		end
		Fs_LI0: begin
			FS_write_enable_a <= 1'b1;
			if(data_fetch_flag == 1'b1)begin
				FS_SRAM_address <= Y_STARTING_DATA_ADDRESS + row_data_address + column_data_address; //Y0
			end else begin
				FS_SRAM_address <= UV_STARTING_DATA_ADDRESS + row_data_address + column_data_address; 
			end
			column_data_index <= column_data_index + 2'd1;
			
			Fs_state <= Fs_LI1;
		end
		
		Fs_LI1: begin
			if(data_fetch_flag == 1'b1)begin
				FS_SRAM_address <= Y_STARTING_DATA_ADDRESS + row_data_address + column_data_address; //Y1
			end else begin
				FS_SRAM_address <= UV_STARTING_DATA_ADDRESS + row_data_address + column_data_address; 
			end
			column_data_index <= column_data_index + 2'd1;
			
			Fs_state <= Fs_LI2;
		end
		
		Fs_LI2: begin
			if(data_fetch_flag == 1'b1)begin
				FS_SRAM_address <= Y_STARTING_DATA_ADDRESS + row_data_address + column_data_address; //Y2
			end else begin
				FS_SRAM_address <= UV_STARTING_DATA_ADDRESS + row_data_address + column_data_address; 
			end
			column_data_index <= column_data_index + 2'd1;
			
			Fs_state <= Fs_CC0;
		end
		
		Fs_CC0: begin
			if(data_fetch_flag == 1'b1)begin
				FS_SRAM_address <= Y_STARTING_DATA_ADDRESS + row_data_address + column_data_address; //Y3
			end else begin
				FS_SRAM_address <= UV_STARTING_DATA_ADDRESS + row_data_address + column_data_address; 
			end
			column_data_index <= column_data_index + 2'd1;
			
			y_buffer[31:16] <= $signed(SRAM_read_data); //Y0
			if (FS_address_a > 7'd0) begin
				FS_address_a <= FS_address_a + 1'b1;
			end
				
			Fs_state <= Fs_CC1;
		end
		Fs_CC1: begin
			if(data_fetch_flag == 1'b1)begin
				FS_SRAM_address <= Y_STARTING_DATA_ADDRESS + row_data_address + column_data_address; //Y4
			end else begin
				FS_SRAM_address <= UV_STARTING_DATA_ADDRESS + row_data_address + column_data_address; 
			end
			column_data_index <= column_data_index + 2'd1;
			
			y_buffer[15:0] <= $signed(SRAM_read_data); //Y0Y1
			
			//FS_write_enable_a <= 1'b1;
			write_data_a <= {y_buffer[31:16], SRAM_read_data};  //YOY1
			//FS_address_a <= FS_address_a + 1'b1;
			
			Fs_state <= Fs_CC2;
		end
		Fs_CC2: begin
			if(data_fetch_flag == 1'b1)begin
				FS_SRAM_address <= Y_STARTING_DATA_ADDRESS + row_data_address + column_data_address; //Y5
			end else begin
				FS_SRAM_address <= UV_STARTING_DATA_ADDRESS + row_data_address + column_data_address; 
			end
			column_data_index <= column_data_index + 2'd1;
			
			//FS_write_enable_a <= 1'b0;
			FS_address_a <= FS_address_a + 1'b1;

			
			y_buffer[31:16] <= $signed(SRAM_read_data); //Y2
			
			Fs_state <= Fs_CC3;
		end
		Fs_CC3: begin
			if(data_fetch_flag == 1'b1)begin
				FS_SRAM_address <= Y_STARTING_DATA_ADDRESS + row_data_address + column_data_address; //Y6
			end else begin
				FS_SRAM_address <= UV_STARTING_DATA_ADDRESS + row_data_address + column_data_address; 
			end
			column_data_index <= column_data_index + 2'd1;
			
			y_buffer[15:0] <= $signed(SRAM_read_data); //Y2Y3
			
			//FS_write_enable_a <= 1'b1;
			write_data_a <= {y_buffer[31:16], SRAM_read_data};  //Y2Y3
	
			Fs_state <= Fs_CC4;
		end
		Fs_CC4: begin
			//FS_SRAM_address <= Y_STARTING_DATA_ADDRESS + row_data_address + column_data_address; //Y7
			//Y_address_counter <= Y_address_counter + 18'd313;
			
			if(data_fetch_flag == 1'b1)begin
				FS_SRAM_address <= Y_STARTING_DATA_ADDRESS + row_data_address + column_data_address; //Y7
			end else begin
				FS_SRAM_address <= UV_STARTING_DATA_ADDRESS + row_data_address + column_data_address; 
			end
			
			if(column_data_index == 18'd7)begin
				row_data_index <= row_data_index + 18'd1; //2 3 4 5 6 7
				column_data_index <= 18'd0;
			end
			
			//FS_write_enable_a <= 1'b0;
			FS_address_a <= FS_address_a + 1'b1;
			y_buffer[31:16] <= $signed(SRAM_read_data); //Y4
			
			if(column_data_index == 18'd7 && row_data_index == 18'd7)begin
				column_data_block <= column_data_block + 18'd1;
				Fs_state <= Fs_LO0;
			end
			else Fs_state <= Fs_CC5;
					
		end
		Fs_CC5: begin
			if(data_fetch_flag == 1'b1)begin
				FS_SRAM_address <= Y_STARTING_DATA_ADDRESS + row_data_address + column_data_address; //Y320
			end else begin
				FS_SRAM_address <= UV_STARTING_DATA_ADDRESS + row_data_address + column_data_address; 
			end
			column_data_index <= column_data_index + 2'd1;
			
			//FS_write_enable_a <= 1'b1;
			
			y_buffer[15:0] <= $signed(SRAM_read_data); //Y4Y5
			
			write_data_a <= {y_buffer[31:16], SRAM_read_data};  //Y4Y5
			//FS_address_a <= FS_address_a + 1'b1;
			
			
			Fs_state <= Fs_CC6;
		end
		Fs_CC6: begin
			if(data_fetch_flag == 1'b1)begin
				FS_SRAM_address <= Y_STARTING_DATA_ADDRESS + row_data_address + column_data_address; //Y321
			end else begin
				FS_SRAM_address <= UV_STARTING_DATA_ADDRESS + row_data_address + column_data_address; 
			end
			column_data_index <= column_data_index + 2'd1;
			FS_address_a <= FS_address_a + 1'b1;
			//FS_write_enable_a <= 1'b0;
			
			y_buffer[31:16] <= $signed(SRAM_read_data); //Y6
			
			Fs_state <= Fs_CC7;
			
		end
		Fs_CC7: begin
			if(data_fetch_flag == 1'b1)begin
				FS_SRAM_address <= Y_STARTING_DATA_ADDRESS + row_data_address + column_data_address; //YY322
			end else begin
				FS_SRAM_address <= UV_STARTING_DATA_ADDRESS + row_data_address + column_data_address; 
			end
			column_data_index <= column_data_index + 2'd1;
			
			//FS_write_enable_a <= 1'b1;
			
			y_buffer[15:0] <= $signed(SRAM_read_data); //Y6Y7
			
			write_data_a <= {y_buffer[31:16], SRAM_read_data};  //Y6Y7
			
			
			Fs_state <= Fs_CC0;
		end
		
		Fs_LO0: begin
			
			//FS_write_enable_a <= 1'b1; //to enable write
			
			y_buffer[15:0] <= $signed(SRAM_read_data); //Y2244Y2245
			
			write_data_a <= {y_buffer[31:16], SRAM_read_data};  //Y2244Y2245
			FS_address_a <= FS_address_a + 1'b1;
			
			Fs_state <= Fs_LO1;
		end
		
		Fs_LO1: begin
			
			//FS_write_enable_a <= 1'b0;
			
			y_buffer[31:16] <= $signed(SRAM_read_data); //Y2246
			
			Fs_state <= Fs_LO2;
		end
		
		Fs_LO2: begin
			
			if(column_data_block == 18'd39)begin
				row_data_block <= row_data_block + 18'd1;
				column_data_block <= 18'd0;
				if(row_data_block > 18'd13)begin
					data_fetch_flag <= 1'b0;
				end
			end
			
			y_buffer[15:0] <= $signed(SRAM_read_data); //Y2246y2247
			//FS_write_enable_a <= 1'b1;
			write_data_a <= {y_buffer[31:16], SRAM_read_data};  //Y2246Y2247
			
			FS_stop <= 1'b1;
			
			Fs_state <= Fs_Idle;
		end
endcase
end
end

//---------------------------------------------------Calculate T------------------------------//
always @(posedge Clock or negedge resetn) begin
	if (~resetn) begin
		CT_state <= CT_Idle;
		CT_address_a <= 7'd0; 
		address_b <= 7'd1; 
		CT_address_c <= 7'd0; 
		CT_write_enable_a <= 1'b0;
		write_enable_b <= 1'b0;
		CT_write_enable_c <= 1'b0;
		CT_stop <= 1'b0;
		row_counter <= 7'd0;
		c_column_counter <= 7'd0;
		T_matrix <= 32'sd0;
		CT_write_flag <= 1'b0; 
		
	end else begin
		case (CT_state)

		CT_Idle: begin
			if (CT_start) begin
				CT_state <= CT_LI0;
			end
		end
		
		CT_LI0: begin
			CT_write_enable_a <= 1'b0;
			CT_write_flag <= 1'b0;
			write_enable_b <= 1'b0;
			CT_write_enable_c <= 1'b1;
			CT_address_a <= 7'd0 + row_counter; 
			address_b <= 7'd1 + row_counter;
			CT_address_c <= 7'd0;
			CT_state <= CT_LI1;
			
		end
		
		CT_LI1: begin
			
			CT_address_a <= CT_address_a + 7'd2;
			
			CT_state <= CT_CC0;
			
		end
		
		CT_CC0: begin

			CT_address_a <= CT_address_a + 7'd1; 
			
			CT_multiplication_1 <= $signed(read_data_a[31:16]);
			CT_C_coeffcient_1 <= 7'd0 + c_column_counter;
			
			CT_multiplication_2 <= $signed(read_data_a[15:0]);
			CT_C_coeffcient_2 <= 7'd8 + c_column_counter;
			
			CT_multiplication_3 <= $signed(read_data_b[31:16]);
			CT_C_coeffcient_3 <= 7'd16 + c_column_counter;
			
			T_matrix <= T_matrix + multiplication_1 + multiplication_2; 
			
			if(CT_write_flag == 1'b1)begin
				CT_address_c <= CT_address_c + 7'd1; //check addrssing 
				CT_write_enable_c <= 1'b1; 
				write_data_c <= (T_matrix + multiplication_1 + multiplication_2) >>> 8;
			end
			
			CT_state <= CT_CC1;
			
		end
		
		CT_CC1: begin
			CT_write_flag <= 1'b1;
			CT_address_a <= 7'd0 + row_counter;
			address_b <= 7'd1 + row_counter; 
			
			CT_multiplication_1 <= $signed(read_data_b[15:0]);
			CT_C_coeffcient_1 <= C_matrix_1 + 7'd24 + c_column_counter;
			
			CT_multiplication_2 <= $signed(read_data_a[31:16]);
			CT_C_coeffcient_2 <= C_matrix_2 + 7'd24 + c_column_counter;
			
			CT_multiplication_3 <= $signed(read_data_a[15:0]);
			CT_C_coeffcient_3 <= C_matrix_3 + 7'd24 + c_column_counter;
			
			T_matrix <= multiplication_1 + multiplication_2 + multiplication_3;
			
			
			if(row_counter == 18'd224 && c_column_counter == 7'd7) begin 
					CT_state <= CT_LO0;
				end
				else CT_state <= CT_CC2;
			
		end
		
		CT_CC2: begin
			
			CT_address_a <= CT_address_a + 7'd2;
			
			CT_multiplication_1 <= $signed(read_data_a[31:16]);
			CT_C_coeffcient_1 <= C_matrix_1 + 7'd24 + c_column_counter;
			
			CT_multiplication_2 <= $signed(read_data_a[15:0]);
			CT_C_coeffcient_2 <= C_matrix_2 + 7'd24 + c_column_counter;
			
			
			T_matrix <= T_matrix + multiplication_1 + multiplication_2 + multiplication_3; 
			
			if(c_column_counter == 7'd7)begin
				c_column_counter <= 7'd0;
				row_counter <= row_counter + 18'd32;
			end
			else begin 
				c_column_counter <= c_column_counter + 7'd1;
			end
			
			CT_state <= CT_CC0;
			
		end
		
		CT_LO0: begin

			CT_address_a <= CT_address_a + 7'd2;
			
			CT_state <= CT_LO1;
			
		end
		
		CT_LO1: begin
			
			CT_address_a <= CT_address_a + 7'd1;
			
			CT_multiplication_1 <= $signed(read_data_a[31:16]);
			CT_C_coeffcient_1 <= 7'd0 + c_column_counter;
			
			CT_multiplication_2 <= $signed(read_data_a[15:0]);
			CT_C_coeffcient_2 <= 7'd8 + c_column_counter;
			
			CT_multiplication_3 <= $signed(read_data_b[31:16]);
			CT_C_coeffcient_3 <= 7'd16 + c_column_counter;
			
			CT_state <= CT_LO2;
			
		end
		
		
		CT_LO2: begin
			
			CT_multiplication_1 <= $signed(read_data_b[15:0]);
			CT_C_coeffcient_1 <= C_matrix_1 + 7'd24 + c_column_counter;
			
			CT_multiplication_2 <= $signed(read_data_a[31:16]);
			CT_C_coeffcient_2 <= C_matrix_2 + 7'd24 + c_column_counter;
			
			CT_multiplication_3 <= $signed(read_data_a[15:0]);
			CT_C_coeffcient_3 <= C_matrix_3 + 7'd24 + c_column_counter;
			
			T_matrix <= multiplication_1 + multiplication_2 + multiplication_3; 
			
			CT_state <= CT_LO3;
			
		end
		
		CT_LO3: begin
			
			CT_multiplication_1 <= $signed(read_data_a[31:16]);
			CT_C_coeffcient_1 <= C_matrix_1 + 7'd24 + c_column_counter;
			
			CT_multiplication_2 <= $signed(read_data_a[15:0]);
			CT_C_coeffcient_2 <= C_matrix_2 + 7'd24 + c_column_counter;
			
			T_matrix <= T_matrix + multiplication_1 + multiplication_2 + multiplication_3; 
			
			CT_state <= CT_LO4;
			
		end
		
		CT_LO4: begin
			
			T_matrix <= T_matrix + multiplication_1 + multiplication_2; 
			CT_address_c <= CT_address_c + 7'd1;
			CT_write_enable_c = 1'b1;
			write_data_c <= (T_matrix + multiplication_1 + multiplication_2) >>> 8;
			CT_stop <= 1'b1;
			CT_state <= CT_Idle;
			
		end
endcase
end
end
//---------------------------------------------------Calculate S------------------------------//
always @(posedge Clock or negedge resetn) begin
	if (~resetn) begin
		CS_state <= CS_Idle;
		CS_write_enable_c <= 1'b0;
		CS_write_enable_e <= 1'b0;
		CS_write_enable_f <= 1'b0;
		CS_address_c <= 7'd0;
		CS_address_e <= 7'd0;
		CS_address_f <= 7'd8;
		s1 <= 32'sd0;
		s2 <= 32'sd0;
		s3 <= 32'sd0;
		s_buffer <= 32'sd0;
		CS_stop <= 1'b0;
		write_flag <= 1'b0;
		incrementor_address <= 7'd0;
		column_counter <= 7'd0;
		starting_index1 <= 7'd0; //0 //3 //6
		starting_index2 <= 7'd1; //1 //4 //7
		starting_index3 <= 7'd2; //2 //5 
		
	end else begin
		case (CS_state)
	
		CS_Idle: begin
			if (CS_start) begin
				CS_state <= CS_LI0;
			end
		end
		
		CS_LI0: begin
			CS_write_enable_c <= 1'b0;

			CS_address_c <= 7'd0; //0 //T00
			starting_index1 <= 7'd0; //0 //3 //6
			starting_index2 <= 7'd1; //1 //4 //7
			starting_index3 <= 7'd2; //2 //5 
			CS_state <= CS_LI1;
			
		end
		
		CS_LI1: begin

			CS_address_c <= CS_address_c + 7'd8;//8 //T10
			write_flag <= 1'b0;
			incrementor_address <= 7'd0;
			CS_write_enable_e <= 1'b1;
			CS_write_enable_f <= 1'b1;
			CS_state <= CS_CC0;
			
		end
		
		CS_CC0: begin
			CS_address_c <= CS_address_c + 7'd8; //16 //17 //T20
			CS_multiplication_1 <= $signed(read_data_c[31:0]); //T00
			CS_C_coeffcient_1 <= starting_index1;
			//C_matrix_1 <= 7'd0;
			
			CS_multiplication_2 <= $signed(read_data_c[31:0]);
			CS_C_coeffcient_2 <= starting_index2;
			
			//C_matrix_2 <= 7'd1;
			
			CS_multiplication_3 <= $signed(read_data_c[31:0]);
			CS_C_coeffcient_3 <= starting_index3;
			
			//C_matrix_3 <= 7'd2;
			
			if(write_flag == 1'b1)begin
				CS_address_e <= 7'd0 + incrementor_address;
				write_data_e <= s1;
				CS_address_f <= 7'd8;
				write_data_f <= s2;
				s_buffer <= s3;
				incrementor_address <= incrementor_address + 7'd16;
			end	
			
			CS_state <= CS_CC1;
			
		end
		
		CS_CC1: begin

			CS_address_c <= CS_address_c + 7'd8; //24    //25 //T30
			CS_multiplication_1 <= $signed(read_data_c[31:0]); //T10
			CS_C_coeffcient_1 <= CS_C_coeffcient_1 + 7'd8;
			
			CS_multiplication_2 <= $signed(read_data_c[31:0]);
			CS_C_coeffcient_2 <= CS_C_coeffcient_2 + 7'd8;
			
			CS_multiplication_3 <= $signed(read_data_c[31:0]);
			CS_C_coeffcient_3 <= CS_C_coeffcient_3 + 7'd8;
			
			if(write_flag == 1'b1)begin
				CS_address_e <= 7'd0 + incrementor_address;
				write_data_e <= s_buffer;
			end	
			write_flag <= 1'b1;
			s1 = multiplication_1; 
			s2 = multiplication_2;
			s3 = multiplication_3;
			
			CS_state <= CS_CC2;
			
		end
		
		CS_CC2: begin
			
			CS_address_c <= CS_address_c + 7'd8; //32  //33 //T40
			CS_multiplication_1 <= $signed(read_data_c[31:0]); //T20
			CS_C_coeffcient_1 <= CS_C_coeffcient_1 + 7'd8;
			
			CS_multiplication_2 <= $signed(read_data_c[31:0]);
			CS_C_coeffcient_2 <= CS_C_coeffcient_2 + 7'd8;
			
			CS_multiplication_3 <= $signed(read_data_c[31:0]);
			CS_C_coeffcient_3 <= CS_C_coeffcient_3 + 7'd8;
			
			s1 = s1 + multiplication_1; 
			s2 = s2 + multiplication_2;
			s3 = s3 + multiplication_3;
			
			
			CS_state <= CS_CC3;
			
		end
		
		CS_CC3: begin
			CS_address_c <= CS_address_c + 7'd8; //40 //41 //T50
			CS_multiplication_1 <= $signed(read_data_c[31:0]); //T30
			CS_C_coeffcient_1 <= CS_C_coeffcient_1 + 7'd8;
			
			CS_multiplication_2 <= $signed(read_data_c[31:0]);
			CS_C_coeffcient_2 <= CS_C_coeffcient_2 + 7'd8;
			
			CS_multiplication_3 <= $signed(read_data_c[31:0]);
			CS_C_coeffcient_3 <= CS_C_coeffcient_3 + 7'd8;
			
			s1 = s1 + multiplication_1; 
			s2 = s2 + multiplication_2;
			s3 = s3 + multiplication_3;
			
			
			CS_state <= CS_CC4;
			
		end
		
		CS_CC4: begin
			CS_address_c <= CS_address_c + 7'd8; //48  //49 //T60
			CS_multiplication_1 <= $signed(read_data_c[31:0]); //T40
			CS_C_coeffcient_1 <= CS_C_coeffcient_1 + 7'd8;
			
			CS_multiplication_2 <= $signed(read_data_c[31:0]);
			CS_C_coeffcient_2 <= CS_C_coeffcient_2 + 7'd8;
			
			CS_multiplication_3 <= $signed(read_data_c[31:0]);
			CS_C_coeffcient_3 <= CS_C_coeffcient_3 + 7'd8;
			
			s1 = s1 + multiplication_1; 
			s2 = s2 + multiplication_2;
			s3 = s3 + multiplication_3;
			
			
			CS_state <= CS_CC5;
			
		end
		
		CS_CC5: begin
			CS_address_c <= CS_address_c + 7'd8; //56  //57 //58 //59 //60 //61 //62 //63 //T70
			CS_multiplication_1 <= $signed(read_data_c[31:0]); //T50  //T67 
			CS_C_coeffcient_1 <= CS_C_coeffcient_1 + 7'd8;
			
			CS_multiplication_2 <= $signed(read_data_c[31:0]);
			CS_C_coeffcient_2 <= CS_C_coeffcient_2 + 7'd8;
			
			CS_multiplication_3 <= $signed(read_data_c[31:0]);
			CS_C_coeffcient_3 <= CS_C_coeffcient_3 + 7'd8;
			
			s1 = s1 + multiplication_1; 
			s2 = s2 + multiplication_2;
			s3 = s3 + multiplication_3;
			
			if(column_counter == 7'd7)begin
				column_counter <= 7'd0;
				starting_index1 <= starting_index1 + 7'd3; //0 //3 //6
				starting_index2 <= starting_index2 + 7'd3; //1 //4 //7
				starting_index3 <= starting_index3 + 7'd3; //2 //5
				if(starting_index1 == 7'd6 && starting_index2 == 7'd7)begin
					CS_state <= CS_LO0;
				end
				else CS_state <= CS_CC6;
				
			end
			
			else column_counter <= column_counter + 7'd1;
			
		end
		
		CS_CC6: begin
			CS_address_c <= column_counter; //1 //2
			
			
			CS_multiplication_1 <= $signed(read_data_c[31:0]); //T60
			CS_C_coeffcient_1 <= CS_C_coeffcient_1 + 7'd8;
			
			CS_multiplication_2 <= $signed(read_data_c[31:0]);
			CS_C_coeffcient_2 <= CS_C_coeffcient_2 + 7'd8;
			
			CS_multiplication_3 <= $signed(read_data_c[31:0]);
			CS_C_coeffcient_3 <= CS_C_coeffcient_3 + 7'd8;
			
			s1 = s1 + multiplication_1; 
			s2 = s2 + multiplication_2;
			s3 = s3 + multiplication_3;
			
			
		end
		
		CS_CC7: begin
			CS_address_c <= column_counter; //9
			CS_multiplication_1 <= $signed(read_data_c[31:0]); //T70
			CS_C_coeffcient_1 <= CS_C_coeffcient_1 + 7'd8;
			
			CS_multiplication_2 <= $signed(read_data_c[31:0]);
			CS_C_coeffcient_2 <= CS_C_coeffcient_2 + 7'd8;
			
			CS_multiplication_3 <= $signed(read_data_c[31:0]);
			CS_C_coeffcient_3 <= CS_C_coeffcient_3 + 7'd8;
			
			s1 = s1 + multiplication_1; 
			s2 = s2 + multiplication_2;
			s3 = s3 + multiplication_3;
			
			
			CS_state <= CS_CC8;
			
		end
		
		CS_CC8: begin
			CS_address_c <= CS_address_c + 7'd8;//17
			CS_multiplication_1 <= $signed(read_data_c[31:0]); //T01
			CS_C_coeffcient_1 <= CS_C_coeffcient_1 + 7'd8;
			
			CS_multiplication_2 <= $signed(read_data_c[31:0]);
			CS_C_coeffcient_2 <= CS_C_coeffcient_2 + 7'd8;
			
			CS_multiplication_3 <= $signed(read_data_c[31:0]);
			CS_C_coeffcient_3 <= CS_C_coeffcient_3 + 7'd8;
			
			s1 = s1 + multiplication_1; 
			s2 = s2 + multiplication_2;
			s3 = s3 + multiplication_3;
			
			
			CS_state <= CS_CC0;
			
		end
		
		CS_LO0: begin
			CS_multiplication_1 <= $signed(read_data_c[31:0]);  //T77 
			CS_C_coeffcient_1 <= CS_C_coeffcient_1 + 7'd8; //row 6
			
			CS_multiplication_2 <= $signed(read_data_c[31:0]);
			CS_C_coeffcient_2 <= CS_C_coeffcient_2 + 7'd8; //row 7
			
			CS_multiplication_3 <= $signed(read_data_c[31:0]);
			CS_C_coeffcient_3 <= CS_C_coeffcient_3 + 7'd8; //this will defualt to 0 
			
			s1 = s1 + multiplication_1; 
			s2 = s2 + multiplication_2;
			s3 = s3 + multiplication_3;
			
			CS_state <= CS_LO1;
			
		end
		
		CS_LO1: begin
			CS_address_e <= CS_address_e + 7'd8;
			CS_address_f <= CS_address_f + 7'd8;
			write_data_e <= s1 + multiplication_1; 
			write_data_f <= s2 + multiplication_2;
			
			
			CS_stop <= 1'b1;
			CS_state <= CS_Idle;
			
		end
		
		
endcase
end
end

//---------------------------------------------------Write S------------------------------//
always @(posedge Clock or negedge resetn) begin
	if (~resetn) begin
		Ws_state <= Ws_Idle;
		WS_SRAM_we_n <= 1'b1;
		WS_SRAM_address <= 18'b0;
		WS_SRAM_write_data <= 16'b0;
		Ws_stop <= 1'b0;
		WS_write_enable_e <= 1'b0;
		WS_write_enable_f <= 1'b0;
		sram_counter <= 18'b0;
		Ws_stop <= 1'b0;
		WS_address_e <= 7'd0; 
		WS_address_f <= 7'd1; 
		sram_starting_address <= 18'b0;
		
	end else begin
		case (Ws_state)

		Ws_Idle: begin
			if (WS_start) begin
				Ws_state <= Ws_LI0;
			end
		end
		
		Ws_LI0: begin
			WS_write_enable_e <= 1'b0;
			WS_write_enable_f <= 1'b0;
			WS_SRAM_address <= sram_starting_address;
			WS_address_e <= 7'd0;
			WS_address_f <= 7'd1;

			Ws_state <= Ws_LI1;
			
			
		end
		
		Ws_LI1: begin
			WS_SRAM_address <= WS_SRAM_address + 18'b1;
			WS_address_e <= WS_address_e + 7'd2;
			WS_address_f <= WS_address_f + 7'd2;
			
			Ws_state <= Ws_CC0;
			
		end
		
		Ws_CC0: begin
			WS_SRAM_address <= WS_SRAM_address + 18'b1;
			WS_address_e <= WS_address_e + 7'd2;
			WS_address_f <= WS_address_f + 7'd2;
			
			WS_SRAM_we_n <= 1'b0; //write mode
			WS_SRAM_write_data <= {read_data_e[7:0],read_data_f[7:0]}; //S0S1
			
			sram_counter <= sram_counter + 18'b1;
			
			Ws_state <= Ws_CC1;
			
		end
		
		Ws_CC1: begin
			WS_SRAM_address <= WS_SRAM_address + 18'b1; //first row done
			WS_address_e <= WS_address_e + 7'd2;
			WS_address_f <= WS_address_f + 7'd2;
			
			WS_SRAM_we_n <= 1'b0; //write mode
			WS_SRAM_write_data <= {read_data_e[7:0],read_data_f[7:0]}; //S2S3
			
			sram_counter <= sram_counter + 18'b1;
			
			Ws_state <= Ws_CC2;
			
		end
		
		Ws_CC2: begin
			WS_SRAM_address <= WS_SRAM_address + 18'b1;
			WS_address_e <= WS_address_e + 7'd2;
			WS_address_f <= WS_address_f + 7'd2;
			
			WS_SRAM_we_n <= 1'b0; //write mode
			WS_SRAM_write_data <= {read_data_e[7:0],read_data_f[7:0]}; //S4S5
			
			sram_counter <= sram_counter + 18'b1;
			
			Ws_state <= Ws_CC3;
			
		end
		
		Ws_CC3: begin
			WS_SRAM_address <= WS_SRAM_address + 18'b1;
			WS_address_e <= WS_address_e + 7'd2;
			WS_address_f <= WS_address_f + 7'd2;
			
			WS_SRAM_we_n <= 1'b0; //write mode
			WS_SRAM_write_data <= {read_data_e[7:0],read_data_f[7:0]}; //S6S7
			
			sram_counter <= sram_counter + 18'b1;
			
			if(sram_counter == 18'd31)begin
				Ws_state <= Ws_LO0;
			end
			
			else Ws_state <= Ws_CC0;
			
		end
		
		Ws_LO0: begin
			sram_starting_address <= sram_starting_address + 18'd64;
			WS_stop <= 1'b1;
			Ws_state <= Ws_Idle;
			
		end
		
endcase
end
end

//-------------------------------------------------------------------------------//

always_comb begin
    if (M2_state == FS || M2_state == Mega_State_1) begin
        SRAM_address = FS_SRAM_address;
    end else if (M2_state == WS || M2_state == Mega_State_2) begin
        SRAM_address = WS_SRAM_address;
    end else begin
        SRAM_address = 18'd0;
    end
end

always_comb begin
    if (M2_state == FS || M2_state == Mega_State_1) begin
        SRAM_write_data = FS_SRAM_write_data;
    end else if (M2_state == WS || M2_state == Mega_State_2) begin
        SRAM_write_data = WS_SRAM_write_data;
    end else begin
        SRAM_write_data = 18'd0;
    end
end

always_comb begin
    if (M2_state == FS || M2_state == Mega_State_1) begin
        SRAM_we_n = FS_SRAM_we_n;
    end else if (M2_state == WS || M2_state == Mega_State_2) begin
        SRAM_we_n = WS_SRAM_we_n;
    end else begin
        SRAM_we_n = 1'b1;
    end
end


//-------------------------------------------------------------------------------------------------------------------------//

always_comb begin
    if (M2_state == CT) begin
        mult_op_1 = CT_multiplication_1;
    end else if (M2_state == CS) begin
        mult_op_1 = CS_multiplication_1;
    end else begin
        mult_op_1 = 32'd0;
    end
end

always_comb begin
    if (M2_state == CT) begin
        mult_op_2 = CT_multiplication_2;
    end else if (M2_state == CS) begin
        mult_op_2 = CS_multiplication_2;
    end else begin
        mult_op_2 = 32'd0;
    end
end

always_comb begin
    if (M2_state == CT) begin
        mult_op_3 = CT_multiplication_3;
    end else if (M2_state == CS) begin
        mult_op_3 = CS_multiplication_3;
    end else begin
        mult_op_3 = 32'd0;
    end
end


//----------------------------------------------------------------//

always_comb begin
    if (M2_state == CT) begin
        C_matrix_1 = CT_C_coeffcient_1;
    end else if (M2_state == CS) begin
        C_matrix_1 = CS_C_coeffcient_1;
    end else begin
        C_matrix_1 = 6'd0;
    end
end

always_comb begin
    if (M2_state == CT) begin
        C_matrix_2 = CT_C_coeffcient_2;
    end else if (M2_state == CS) begin
        C_matrix_2 = CS_C_coeffcient_2;
    end else begin
        C_matrix_2 = 6'd0;
    end
end

always_comb begin
    if (M2_state == CT) begin
        C_matrix_3 = CT_C_coeffcient_3;
    end else if (M2_state == CS) begin
        C_matrix_3 = CS_C_coeffcient_3;
    end else begin
        C_matrix_3 = 6'd0;
    end
end



//--------------------------------------------------------------------------------------------//

always_comb begin
    if (M2_state == FS || M2_state == Mega_State_1) begin
        write_enable_a = FS_write_enable_a;
    end else if (M2_state == CT || M2_state == Mega_State_2) begin
        write_enable_a = CT_write_enable_a;
    end else begin
        write_enable_a = 1'b0;
    end
end

always_comb begin
    if (M2_state == CT || M2_state == Mega_State_2) begin
        write_enable_c = CT_write_enable_c;
    end else if (M2_state == CS || M2_state == Mega_State_1) begin
        write_enable_c = CS_write_enable_c;
    end else begin
        write_enable_c = 1'b0;
    end
end

always_comb begin
    if (M2_state == CS || M2_state == Mega_State_1) begin
        write_enable_e = CS_write_enable_e;
    end else if (M2_state == WS || M2_state == Mega_State_2) begin
        write_enable_e = WS_write_enable_e;
    end else begin
        write_enable_e = 1'b0;
    end
end

always_comb begin
    if (M2_state == CS || M2_state == Mega_State_1) begin
        write_enable_f = CS_write_enable_f;
    end else if (M2_state == WS || M2_state == Mega_State_2) begin
        write_enable_f = WS_write_enable_f;
    end else begin
        write_enable_f = 1'b0;
    end
end


//----------------------------------------------------------------//
always_comb begin
    if (M2_state == FS) begin
        address_a = FS_address_a;
    end else if (M2_state == CT) begin
        address_a = CT_address_a;
    end else begin
        address_a = 7'd0;
    end
end

always_comb begin
    if (M2_state == CS) begin
        address_c = CS_address_c;
    end else if (M2_state == CT) begin
        address_c = CT_address_c;
    end else begin
        address_c = 7'd0;
    end
end

always_comb begin
    if (M2_state == WS) begin
        address_e = WS_address_e;
    end else if (M2_state == CS) begin
        address_e = CS_address_e;
    end else begin
        address_e = 7'd0;
    end
end

always_comb begin
    if (M2_state == WS) begin
        address_f = WS_address_f;
    end else if (M2_state == CS) begin
        address_f = CS_address_f;
    end else begin
        address_f = 7'd0;
    end
end

//------------------------------------------------------------//

always_comb begin
    
    if (data_fetch_flag == 1'b1) begin
        row_data_address = ({row_data_block, row_data_index[2:0]} << 8) + 
                           ({row_data_block, row_data_index[2:0]} << 6);
    end else begin
        row_data_address = ({row_data_block, row_data_index[2:0]} << 7) + 
                           ({row_data_block, row_data_index[2:0]} << 5);
    end

    
    if (data_fetch_flag == 1'b1) begin
        column_data_address = {column_data_block, column_data_index[2:0]};
    end else begin
        column_data_address = {column_data_block, column_data_index[2:0]};
    end
end


always_comb begin
	case(C_matrix_1)
			//first row
		0:   C_coeffcient_1 = 32'sd1448;   
		1:   C_coeffcient_1 = 32'sd1448;   
		2:   C_coeffcient_1 = 32'sd1448;   
		3:   C_coeffcient_1 = 32'sd1448;   
		4:   C_coeffcient_1 = 32'sd1448;   
		5:   C_coeffcient_1 = 32'sd1448;   
		6:   C_coeffcient_1 = 32'sd1448;   
		7:   C_coeffcient_1 = 32'sd1448; 
			//second row
		8:   C_coeffcient_1 = 32'sd2008;   
		9:   C_coeffcient_1 = 32'sd1702;   
		10:  C_coeffcient_1 = 32'sd1137;   
		11:  C_coeffcient_1 = 32'sd399;    
		12:  C_coeffcient_1 = -32'sd399;   
		13:  C_coeffcient_1 = -32'sd1137;  
		14:  C_coeffcient_1 = -32'sd1702;  
		15:  C_coeffcient_1 = -32'sd2008;
			//third row 
		16:  C_coeffcient_1 = 32'sd1892;   
		17:  C_coeffcient_1 = 32'sd783;    
		18:  C_coeffcient_1 = -32'sd783;   
		19:  C_coeffcient_1 = -32'sd1892;  
		20:  C_coeffcient_1 = -32'sd1892;  
		21:  C_coeffcient_1 = -32'sd783;   
		22:  C_coeffcient_1 = 32'sd783;    
		23:  C_coeffcient_1 = 32'sd1892;
			//fourth row
		24:  C_coeffcient_1 = 32'sd1702;
		25:  C_coeffcient_1 = -32'sd399;   
		26:  C_coeffcient_1 = -32'sd2008;  
		27:  C_coeffcient_1 = -32'sd1137;  
		28:  C_coeffcient_1 = 32'sd1137;   
		29:  C_coeffcient_1 = 32'sd2008;   
		30:  C_coeffcient_1 = 32'sd399;    
		31:  C_coeffcient_1 = -32'sd1702;
			//fifth row
		32:  C_coeffcient_1 = 32'sd1448;   
		33:  C_coeffcient_1 = -32'sd1448;  
		34:  C_coeffcient_1 = -32'sd1448;  
		35:  C_coeffcient_1 = 32'sd1448;   
		36:  C_coeffcient_1 = 32'sd1448;   
		37:  C_coeffcient_1 = -32'sd1448;  
		38:  C_coeffcient_1 = -32'sd1448;  
		39:  C_coeffcient_1 = 32'sd1448;
			//sixth row 
		40:  C_coeffcient_1 = 32'sd1137;   
		41:  C_coeffcient_1 = -32'sd2008;  
		42:  C_coeffcient_1 = 32'sd399;    
		43:  C_coeffcient_1 = 32'sd1702;   
		44:  C_coeffcient_1 = -32'sd1702;  
		45:  C_coeffcient_1 = -32'sd399;   
		46:  C_coeffcient_1 = 32'sd2008;   
		47:  C_coeffcient_1 = -32'sd1137;  
			//seventh row
		48:  C_coeffcient_1 = 32'sd783;    
		49:  C_coeffcient_1 = -32'sd1892;  
		50:  C_coeffcient_1 = 32'sd1892;   
		51:  C_coeffcient_1 = -32'sd783;   
		52:  C_coeffcient_1 = -32'sd783;   
		53:  C_coeffcient_1 = 32'sd1892;   
		54:  C_coeffcient_1 = -32'sd1892;  
		55:  C_coeffcient_1 = 32'sd783;
			//eighth row 
		56:  C_coeffcient_1 = 32'sd399;    
		57:  C_coeffcient_1 = -32'sd1137;  
		58:  C_coeffcient_1 = 32'sd1702;   
		59:  C_coeffcient_1 = -32'sd2008;  
		60:  C_coeffcient_1 = 32'sd2008;   
		61:  C_coeffcient_1 = -32'sd1702;  
		62:  C_coeffcient_1 = 32'sd1137;   
		63:  C_coeffcient_1 = -32'sd399;    
		default:  C_coeffcient_1 = 32'sd0;  
	endcase
end

always_comb begin
	case(C_matrix_2)
			
		0:   C_coeffcient_2 = 32'sd1448;   
		1:   C_coeffcient_2 = 32'sd1448;   
		2:   C_coeffcient_2 = 32'sd1448;   
		3:   C_coeffcient_2 = 32'sd1448;   
		4:   C_coeffcient_2 = 32'sd1448;   
		5:   C_coeffcient_2 = 32'sd1448;   
		6:   C_coeffcient_2 = 32'sd1448;   
		7:   C_coeffcient_2 = 32'sd1448; 
			
		8:   C_coeffcient_2 = 32'sd2008;   
		9:   C_coeffcient_2 = 32'sd1702;   
		10:  C_coeffcient_2 = 32'sd1137;   
		11:  C_coeffcient_2 = 32'sd399;    
		12:  C_coeffcient_2 = -32'sd399;   
		13:  C_coeffcient_2 = -32'sd1137;  
		14:  C_coeffcient_2 = -32'sd1702;  
		15:  C_coeffcient_2 = -32'sd2008;
			
		16:  C_coeffcient_2 = 32'sd1892;   
		17:  C_coeffcient_2 = 32'sd783;    
		18:  C_coeffcient_2 = -32'sd783;   
		19:  C_coeffcient_2 = -32'sd1892;  
		20:  C_coeffcient_2 = -32'sd1892;  
		21:  C_coeffcient_2 = -32'sd783;   
		22:  C_coeffcient_2 = 32'sd783;    
		23:  C_coeffcient_2 = 32'sd1892;
			
		24:  C_coeffcient_2 = 32'sd1702;
		25:  C_coeffcient_2 = -32'sd399;   
		26:  C_coeffcient_2 = -32'sd2008;  
		27:  C_coeffcient_2 = -32'sd1137;  
		28:  C_coeffcient_2 = 32'sd1137;   
		29:  C_coeffcient_2 = 32'sd2008;   
		30:  C_coeffcient_2 = 32'sd399;    
		31:  C_coeffcient_2 = -32'sd1702;
			
		32:  C_coeffcient_2 = 32'sd1448;   
		33:  C_coeffcient_2 = -32'sd1448;  
		34:  C_coeffcient_2 = -32'sd1448;  
		35:  C_coeffcient_2 = 32'sd1448;   
		36:  C_coeffcient_2 = 32'sd1448;   
		37:  C_coeffcient_2 = -32'sd1448;  
		38:  C_coeffcient_2 = -32'sd1448;  
		39:  C_coeffcient_2 = 32'sd1448;
			
		40:  C_coeffcient_2 = 32'sd1137;   
		41:  C_coeffcient_2 = -32'sd2008;  
		42:  C_coeffcient_2 = 32'sd399;    
		43:  C_coeffcient_2 = 32'sd1702;   
		44:  C_coeffcient_2 = -32'sd1702;  
		45:  C_coeffcient_2 = -32'sd399;   
		46:  C_coeffcient_2 = 32'sd2008;   
		47:  C_coeffcient_2 = -32'sd1137;  
			
		48:  C_coeffcient_2 = 32'sd783;    
		49:  C_coeffcient_2 = -32'sd1892;  
		50:  C_coeffcient_2 = 32'sd1892;   
		51:  C_coeffcient_2 = -32'sd783;   
		52:  C_coeffcient_2 = -32'sd783;   
		53:  C_coeffcient_2 = 32'sd1892;   
		54:  C_coeffcient_2 = -32'sd1892;  
		55:  C_coeffcient_2 = 32'sd783;
			
		56:  C_coeffcient_2 = 32'sd399;    
		57:  C_coeffcient_2 = -32'sd1137;  
		58:  C_coeffcient_2 = 32'sd1702;   
		59:  C_coeffcient_2 = -32'sd2008;  
		60:  C_coeffcient_2 = 32'sd2008;   
		61:  C_coeffcient_2 = -32'sd1702;  
		62:  C_coeffcient_2 = 32'sd1137;   
		63:  C_coeffcient_2 = -32'sd399;    
		default:  C_coeffcient_2 = 32'sd0;   
	endcase
end

always_comb begin
	case(C_matrix_3)
			
		0:   C_coeffcient_3 = 32'sd1448;   
		1:   C_coeffcient_3 = 32'sd1448;   
		2:   C_coeffcient_3 = 32'sd1448;   
		3:   C_coeffcient_3 = 32'sd1448;   
		4:   C_coeffcient_3 = 32'sd1448;   
		5:   C_coeffcient_3 = 32'sd1448;   
		6:   C_coeffcient_3 = 32'sd1448;   
		7:   C_coeffcient_3 = 32'sd1448; 
			
		8:   C_coeffcient_3 = 32'sd2008;   
		9:   C_coeffcient_3 = 32'sd1702;   
		10:  C_coeffcient_3 = 32'sd1137;   
		11:  C_coeffcient_3 = 32'sd399;    
		12:  C_coeffcient_3 = -32'sd399;   
		13:  C_coeffcient_3 = -32'sd1137;  
		14:  C_coeffcient_3 = -32'sd1702;  
		15:  C_coeffcient_3 = -32'sd2008;
			
		16:  C_coeffcient_3 = 32'sd1892;   
		17:  C_coeffcient_3 = 32'sd783;    
		18:  C_coeffcient_3 = -32'sd783;   
		19:  C_coeffcient_3 = -32'sd1892;  
		20:  C_coeffcient_3 = -32'sd1892;  
		21:  C_coeffcient_3 = -32'sd783;   
		22:  C_coeffcient_3 = 32'sd783;    
		23:  C_coeffcient_3 = 32'sd1892;
			
		24:  C_coeffcient_3 = 32'sd1702;
		25:  C_coeffcient_3 = -32'sd399;   
		26:  C_coeffcient_3 = -32'sd2008;  
		27:  C_coeffcient_3 = -32'sd1137;  
		28:  C_coeffcient_3 = 32'sd1137;   
		29:  C_coeffcient_3 = 32'sd2008;   
		30:  C_coeffcient_3 = 32'sd399;    
		31:  C_coeffcient_3 = -32'sd1702;
			
		32:  C_coeffcient_3 = 32'sd1448;   
		33:  C_coeffcient_3 = -32'sd1448;  
		34:  C_coeffcient_3 = -32'sd1448;  
		35:  C_coeffcient_3 = 32'sd1448;   
		36:  C_coeffcient_3 = 32'sd1448;   
		37:  C_coeffcient_3 = -32'sd1448;  
		38:  C_coeffcient_3 = -32'sd1448;  
		39:  C_coeffcient_3 = 32'sd1448;
			
		40:  C_coeffcient_3 = 32'sd1137;   
		41:  C_coeffcient_3 = -32'sd2008;  
		42:  C_coeffcient_3 = 32'sd399;    
		43:  C_coeffcient_3 = 32'sd1702;   
		44:  C_coeffcient_3 = -32'sd1702;  
		45:  C_coeffcient_3 = -32'sd399;   
		46:  C_coeffcient_3 = 32'sd2008;   
		47:  C_coeffcient_3 = -32'sd1137;  
		
		48:  C_coeffcient_3 = 32'sd783;    
		49:  C_coeffcient_3 = -32'sd1892;  
		50:  C_coeffcient_3 = 32'sd1892;   
		51:  C_coeffcient_3 = -32'sd783;   
		52:  C_coeffcient_3 = -32'sd783;   
		53:  C_coeffcient_3 = 32'sd1892;   
		54:  C_coeffcient_3 = -32'sd1892;  
		55:  C_coeffcient_3 = 32'sd783;
		
		56:  C_coeffcient_3 = 32'sd399;    
		57:  C_coeffcient_3 = -32'sd1137;  
		58:  C_coeffcient_3 = 32'sd1702;   
		59:  C_coeffcient_3 = -32'sd2008;  
		60:  C_coeffcient_3 = 32'sd2008;   
		61:  C_coeffcient_3 = -32'sd1702;  
		62:  C_coeffcient_3 = 32'sd1137;   
		63:  C_coeffcient_3 = -32'sd399;    
		default:  C_coeffcient_3 = 32'sd0;  
	endcase
end



endmodule