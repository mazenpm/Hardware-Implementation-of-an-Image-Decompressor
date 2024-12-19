
mem save -o SRAM.mem -f mti -data hex -addr hex -startaddress 0 -endaddress 262143 -wordsperline 8 /TB/SRAM_component/SRAM_data


if {[file exists $rtl/RAM_init.ver]} {
    file delete $rtl/RAM_init.ver
}
mem save -o RAM_init.mem -f mti -data hex -addr dec -wordsperline 1 /TB/UUT/M2_unit/dualport/altsyncram_component/m_default/altsyncram_inst/mem_data

if {[file exists $rtl/RAM_init1.ver]} {
    file delete $rtl/RAM_init1.ver
}
mem save -o RAM_init1.mem -f mti -data hex -addr dec -wordsperline 1 /TB/UUT/M2_unit/dualport1/altsyncram_component/m_default/altsyncram_inst/mem_data

if {[file exists $rtl/RAM_init2.ver]} {
    file delete $rtl/RAM_init2.ver
}
mem save -o RAM_init2.mem -f mti -data hex -addr dec -wordsperline 1 /TB/UUT/M2_unit/dualport2/altsyncram_component/m_default/altsyncram_inst/mem_data
