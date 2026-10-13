##############################
# BOARD SPECIFIC CONSTRAINTS #
##############################

#############
# Sys clock #
#############

# 250 MHz ref clock (C1 DDR4 reference, shared with the clock wizard)
set SYS_TCK 4
create_clock -period $SYS_TCK -name sys_clk [get_pins u_ibufg_sys_clk/O]
set_property CLOCK_DEDICATED_ROUTE BACKBONE [get_pins u_ibufg_sys_clk/O]

#############
# Mig clock #
#############

# Dram axi clock : 833ps * 4
set MIG_TCK 3.332
create_generated_clock -source [get_pins i_dram_wrapper/i_dram/inst/u_ddr4_infrastructure/gen_mmcme4.u_mmcme_adv_inst/CLKOUT0] \
 -divide_by 1 -add -master_clock mmcm_clkout0 -name dram_axi_clk [get_pins i_dram_wrapper/i_dram/c0_ddr4_ui_clk]
# Async reset in
set MIG_RST_I [get_pin i_dram_wrapper/i_dram/inst/c0_ddr4_aresetn]
set_false_path -hold -setup -through $MIG_RST_I
# Synch reset out
set MIG_RST_O [get_pins i_dram_wrapper/i_dram/c0_ddr4_ui_clk_sync_rst]
set_false_path -hold -through $MIG_RST_O
set_max_delay -through $MIG_RST_O $MIG_TCK

########
# CDCs #
########

set_max_delay -datapath \
 -from [get_pins i_dram_wrapper/gen_cdc.i_axi_cdc_mig/i_axi_cdc_dst/i_cdc_fifo_gray_*/*reg*/C] \
  -to [get_pins i_dram_wrapper/gen_cdc.i_axi_cdc_mig/i_axi_cdc_src/i_cdc_fifo_gray_*/*i_sync/reg*/D] $MIG_TCK

set_max_delay -datapath \
 -from [get_pins i_dram_wrapper/gen_cdc.i_axi_cdc_mig/i_axi_cdc_src/i_cdc_fifo_gray_*/*reg*/C] \
  -to [get_pins i_dram_wrapper/gen_cdc.i_axi_cdc_mig/i_axi_cdc_dst/i_cdc_fifo_gray_*/*i_sync/reg*/D] 20

set_max_delay -datapath \
 -from [get_pins i_dram_wrapper/gen_cdc.i_axi_cdc_mig/i_axi_cdc_dst/i_cdc_fifo_gray_*/*reg*/C] \
  -to [get_pins i_dram_wrapper/gen_cdc.i_axi_cdc_mig/i_axi_cdc_src/i_cdc_fifo_gray_*/i_spill_register/spill_register_flushable_i/*reg*/D] $MIG_TCK

set_max_delay -datapath \
 -from [get_pins i_dram_wrapper/gen_cdc.i_axi_cdc_mig/i_axi_cdc_src/i_cdc_fifo_gray_*/*reg*/C] \
  -to [get_pins i_dram_wrapper/gen_cdc.i_axi_cdc_mig/i_axi_cdc_dst/i_cdc_fifo_gray_*/i_spill_register/spill_register_flushable_i/*reg*/D] 20

###############
# ASSIGN PINS #
###############

# Pins from the VCU118 pull into Cheshire main reference (PR #240), checked
# against the VCU118 Rev 2.0 master XDC. The DDR4 pins come from the board
# part through the MIG (ddr4_sdram_c1_062 board interface).

# USB-UART (CP2105, J4): FPGA RX is USB_UART_TX, FPGA TX is USB_UART_RX
set_property PACKAGE_PIN AW25     [get_ports "uart_rx_i"] ;# Bank  64 VCCO - VCC1V8_FPGA - IO_L9P_T1L_N4_AD12P_64
set_property IOSTANDARD  LVCMOS18 [get_ports "uart_rx_i"] ;# Bank  64 VCCO - VCC1V8_FPGA - IO_L9P_T1L_N4_AD12P_64
set_property PACKAGE_PIN BB21     [get_ports "uart_tx_o"] ;# Bank  64 VCCO - VCC1V8_FPGA - IO_L8N_T1L_N3_AD5N_64
set_property IOSTANDARD  LVCMOS18 [get_ports "uart_tx_o"] ;# Bank  64 VCCO - VCC1V8_FPGA - IO_L8N_T1L_N3_AD5N_64

# External JTAG on PMOD J53 (level-translated to 3.3 V on the connector side)
set_property PACKAGE_PIN N28     [get_ports jtag_tms_i] ;# PMOD1_0_LS, J53.1 - TMS
set_property IOSTANDARD LVCMOS12 [get_ports jtag_tms_i]
set_property PACKAGE_PIN M30     [get_ports jtag_tdi_i] ;# PMOD1_1_LS, J53.3 - TDI
set_property IOSTANDARD LVCMOS12 [get_ports jtag_tdi_i]
set_property PACKAGE_PIN N30     [get_ports jtag_tdo_o] ;# PMOD1_2_LS, J53.5 - TDO
set_property IOSTANDARD LVCMOS12 [get_ports jtag_tdo_o]
set_property PACKAGE_PIN P30     [get_ports jtag_tck_i] ;# PMOD1_3_LS, J53.7 - TCK
set_property IOSTANDARD LVCMOS12 [get_ports jtag_tck_i]

# CPU reset push button (SW5), active high
set_property PACKAGE_PIN L19 [get_ports cpu_reset] ;# Bank  73 VCCO - VCC1V2_FPGA - IO_T1U_N12_73
set_property IOSTANDARD LVCMOS12 [get_ports cpu_reset]

# 250 MHz differential clock (250MHZ_CLK1, bank 71 at 1.2 V)
set_property IOSTANDARD DIFF_SSTL12 [get_ports sys_clk_n]
set_property IOSTANDARD DIFF_SSTL12 [get_ports sys_clk_p]
set_property PACKAGE_PIN E12 [get_ports sys_clk_p] ;# Bank  71 VCCO - VCC1V2_FPGA - IO_L13P_T2L_N0_GC_QBC_71
set_property PACKAGE_PIN D12 [get_ports sys_clk_n] ;# Bank  71 VCCO - VCC1V2_FPGA - IO_L13N_T2L_N1_GC_QBC_71
