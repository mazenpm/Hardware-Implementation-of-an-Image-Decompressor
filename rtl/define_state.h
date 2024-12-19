`ifndef DEFINE_STATE

// for top state - we have more states than needed
typedef enum logic [1:0] {
	S_IDLE,
	S_UART_RX,
	S_M2,
	S_M1
} top_state_type;

typedef enum logic [1:0] {
	S_RXC_IDLE,
	S_RXC_SYNC,
	S_RXC_ASSEMBLE_DATA,
	S_RXC_STOP_BIT
} RX_Controller_state_type;

typedef enum logic [2:0] {
	S_US_IDLE,
	S_US_STRIP_FILE_HEADER_1,
	S_US_STRIP_FILE_HEADER_2,
	S_US_START_FIRST_BYTE_RECEIVE,
	S_US_WRITE_FIRST_BYTE,
	S_US_START_SECOND_BYTE_RECEIVE,
	S_US_WRITE_SECOND_BYTE
} UART_SRAM_state_type;

typedef enum logic [3:0] {
	S_VS_WAIT_NEW_PIXEL_ROW,
	S_VS_NEW_PIXEL_ROW_DELAY_1,
	S_VS_NEW_PIXEL_ROW_DELAY_2,
	S_VS_NEW_PIXEL_ROW_DELAY_3,
	S_VS_NEW_PIXEL_ROW_DELAY_4,
	S_VS_NEW_PIXEL_ROW_DELAY_5,
	S_VS_FETCH_PIXEL_DATA_0,
	S_VS_FETCH_PIXEL_DATA_1,
	S_VS_FETCH_PIXEL_DATA_2,
	S_VS_FETCH_PIXEL_DATA_3
} VGA_SRAM_state_type;

typedef enum logic [7:0] {
	M1_IDLE,
	S_LI0,
	S_LI1,
	S_LI2,
	S_LI3,
	S_LI4,
	S_LI5,
	S_LI6,
	S_LI7,
	S_LI8,
	S_LI9,
	S_LI10,
	S_LI11,
	S_LI12,
	S_LI13,
	S_LI14,
	S_LI15,
	S_CC0,
	S_CC1,
	S_CC2,
	S_CC3,
	S_CC4,
	S_CC5,
	S_CC6,
	S_LO0,
	S_LO1,
	S_LO2,
	S_LO3,
	S_LO4,
	S_LO5,
	S_LO6,
	S_LO7,
	S_LO8,
	S_LO9
} Milestone_1_state_type;

typedef enum logic [7:0] {
	Fs_Idle,
	Fs_LI0,
	Fs_LI1,
	Fs_LI2,
	Fs_CC0,
	Fs_CC1,
	Fs_CC2,
	Fs_CC3,
	Fs_CC4,
	Fs_CC5,
	Fs_CC6,
	Fs_CC7,
	Fs_LO0,
	Fs_LO1,
	Fs_LO2
} FS_state_type;

typedef enum logic [7:0] {
	CT_Idle,
	CT_LI0,
	CT_LI1,
	CT_LI2,
	CT_CC0,
	CT_CC1,
	CT_CC2,
	CT_LO0,
	CT_LO1,
	CT_LO2,
	CT_LO3,
	CT_LO4
} CT_state_type;

typedef enum logic [7:0] {
	CS_Idle,
	CS_LI0,
	CS_LI1,
	CS_CC0,
	CS_CC1,
	CS_CC2,
	CS_CC3,
	CS_CC4,
	CS_CC5,
	CS_CC6,
	CS_CC7,
	CS_CC8,
	CS_LO0,
	CS_LO1
} CS_state_type;

typedef enum logic [7:0] {
	Ws_Idle,
	Ws_LI0,
	Ws_LI1,
	Ws_CC0,
	Ws_CC1,
	Ws_CC2,
	Ws_CC3,
	Ws_LO0
} WS_state_type;

typedef enum logic [7:0] {
	M2_IDLE,
	FS,
	CT,
	Mega_State_1,
	Mega_State_2,
	CS,
	WS
} Milestone_2_state_type;



parameter U_STARTING_DATA_ADDRESS = 18'd38400;
parameter V_STARTING_DATA_ADDRESS = 18'd57600;
parameter RGB_STARTING_DATA_ADDRESS = 18'd146944;


parameter 
   VIEW_AREA_LEFT = 160,
   VIEW_AREA_RIGHT = 480,
   VIEW_AREA_TOP = 120,
   VIEW_AREA_BOTTOM = 360;

`define DEFINE_STATE 1
`endif
