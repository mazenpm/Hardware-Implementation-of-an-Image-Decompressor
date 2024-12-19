# activate waveform simulation

view wave

# format signal names in waveform

configure wave -signalnamewidth 1
configure wave -timeline 0
configure wave -timelineunits us

# add signals to waveform

add wave -divider -height 20 {Top-level signals}
add wave -bin UUT/CLOCK_50_I
add wave -bin UUT/resetn
add wave UUT/top_state
add wave -uns UUT/UART_timer

add wave UUT/M1_unit/M1_state
add wave UUT/M2_unit/M2_state
add wave UUT/M2_unit/Fs_state
add wave UUT/M2_unit/CT_state
add wave -hex UUT/M2_unit/T_matrix
add wave -hex UUT/M2_unit/write_data_c
add wave -hex UUT/M2_unit/row_counter
add wave -hex UUT/M2_unit/c_column_counter
add wave -decimal UUT/M2_unit/address_a
add wave -decimal UUT/M2_unit/address_b

add wave -decimal UUT/M2_unit/address_c
add wave -hex UUT/M2_unit/CT_write_flag
add wave -decimal UUT/M2_unit/row_counter
add wave -decimal UUT/M2_unit/c_column_counter
add wave UUT/M1_unit/UV_read_flag
add wave UUT/M2_unit/row_data_address
add wave UUT/M2_unit/Y_STARTING_DATA_ADDRESS
add wave UUT/M2_unit/column_data_address
add wave UUT/M2_unit/column_data_block
add wave UUT/M2_unit/column_data_index
add wave -hex UUT/M2_unit/write_data_a
add wave -hex UUT/M2_unit/read_data_a
add wave -decimal UUT/M2_unit/address_a

add wave -divider -height 10 {SRAM signals}
add wave -uns UUT/SRAM_address
add wave -hex UUT/SRAM_write_data
add wave -bin UUT/SRAM_we_n
add wave -hex UUT/SRAM_read_data

#add wave -divider -height 10 {SRAM signals M1}
#add wave -uns UUT/M1_unit/SRAM_address
#add wave -hex UUT/M1_unit/SRAM_write_data
#add wave -bin UUT/M1_unit/SRAM_we_n
#add wave -hex UUT/M1_unit/SRAM_read_data

add wave -divider -height 10 {VGA signals}
add wave -bin UUT/VGA_unit/VGA_HSYNC_O
add wave -bin UUT/VGA_unit/VGA_VSYNC_O
add wave -uns UUT/VGA_unit/pixel_X_pos
add wave -uns UUT/VGA_unit/pixel_Y_pos
add wave -hex UUT/VGA_unit/VGA_red
add wave -hex UUT/VGA_unit/VGA_green
add wave -hex UUT/VGA_unit/VGA_blue
add wave -hex UUT/VGA_unit/VGA_enable

#add wave -divider -height 10 {RGB signals}
#add wave -hex UUT/M1_unit/red
#add wave -hex UUT/M1_unit/green
#add wave -hex UUT/M1_unit/blue
#
#add wave -hex UUT/M1_unit/red_buf
#add wave -hex UUT/M1_unit/green_buf
#add wave -hex UUT/M1_unit/blue_buf
#
#add wave -hex UUT/M1_unit/U_odd_data
#add wave -hex UUT/M1_unit/V_odd_data
#
#add wave -hex UUT/M1_unit/y
#add wave -hex UUT/M1_unit/u
#add wave -hex UUT/M1_unit/v
#add wave -hex UUT/M1_unit/Y_address_counter
#add wave -hex UUT/M1_unit/UV_address_counter
#add wave -hex UUT/M1_unit/RGB_data_counter
#add wave -hex UUT/M1_unit/rows_counter
#add wave -hex UUT/M1_unit/UV_read_flag
