# Clocks
set_property -dict {PACKAGE_PIN U18 IOSTANDARD LVCMOS33} [get_ports FCLK_CLK3_0]
set_property -dict {PACKAGE_PIN K18 IOSTANDARD LVCMOS33} [get_ports CLOCK_OUT]

# Ethernet GMII clocks
set_property -dict {PACKAGE_PIN U14 IOSTANDARD LVCMOS33} [get_ports ENET0_GMII_RX_CLK_0]
set_property -dict {PACKAGE_PIN U15 IOSTANDARD LVCMOS33} [get_ports ENET0_GMII_TX_CLK_0]

# Ethernet GMII RX data[3:0]
set_property -dict {PACKAGE_PIN Y17 IOSTANDARD LVCMOS33} [get_ports {enet0_gmii_rxd[3]}]
set_property -dict {PACKAGE_PIN V17 IOSTANDARD LVCMOS33} [get_ports {enet0_gmii_rxd[2]}]
set_property -dict {PACKAGE_PIN V16 IOSTANDARD LVCMOS33} [get_ports {enet0_gmii_rxd[1]}]
set_property -dict {PACKAGE_PIN Y16 IOSTANDARD LVCMOS33} [get_ports {enet0_gmii_rxd[0]}]

# Ethernet GMII RX_DV
set_property -dict {PACKAGE_PIN W16 IOSTANDARD LVCMOS33} [get_ports ENET0_GMII_RX_DV_0]

# Ethernet GMII TX enable + data[3:0]
set_property -dict {PACKAGE_PIN W19 IOSTANDARD LVCMOS33} [get_ports ENET0_GMII_TX_EN_0]
set_property -dict {PACKAGE_PIN Y19 IOSTANDARD LVCMOS33} [get_ports {enet0_gmii_txd[3]}]
set_property -dict {PACKAGE_PIN V18 IOSTANDARD LVCMOS33} [get_ports {enet0_gmii_txd[2]}]
set_property -dict {PACKAGE_PIN Y18 IOSTANDARD LVCMOS33} [get_ports {enet0_gmii_txd[1]}]
set_property -dict {PACKAGE_PIN W18 IOSTANDARD LVCMOS33} [get_ports {enet0_gmii_txd[0]}]

# MDIO interface
set_property -dict {PACKAGE_PIN W15 IOSTANDARD LVCMOS33} [get_ports MDIO_ETHERNET_0_0_mdc]
set_property -dict {PACKAGE_PIN Y14 IOSTANDARD LVCMOS33} [get_ports MDIO_ETHERNET_0_0_mdio_io]

# LEDs
set_property -dict {PACKAGE_PIN W13 IOSTANDARD LVCMOS33} [get_ports {green}]
set_property -dict {PACKAGE_PIN W14 IOSTANDARD LVCMOS33} [get_ports {red}]


#keys
#set_property -dict {PACKAGE_PIN U19 IOSTANDARD LVCMOS33} [get_ports key1] 
#set_property -dict {PACKAGE_PIN T19 IOSTANDARD LVCMOS33} [get_ports kesy2]
set_property -dict {PACKAGE_PIN G20 IOSTANDARD LVCMOS33 } [get_ports G20] 
set_property -dict {PACKAGE_PIN U19 IOSTANDARD LVCMOS33 } [get_ports U19] 
set_property -dict {PACKAGE_PIN P20 IOSTANDARD LVCMOS33 } [get_ports P20] 
set_property -dict {PACKAGE_PIN U20 IOSTANDARD LVCMOS33 } [get_ports U20] 

set_property LOCK_UPGRADE false [get_bd_cells xlslice_0]
set_property LOCK_UPGRADE false [get_bd_cells xlconcat_0]