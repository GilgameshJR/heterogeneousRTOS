# Definitional proc to organize widgets for parameters.
proc init_gui { IPINST } {
  ipgui::add_param $IPINST -name "Component_Name"
  #Adding Page
  set Page_0 [ipgui::add_page $IPINST -name "Page 0"]
  ipgui::add_param $IPINST -name "C_S00_AXI_IN_BASEADDR" -parent ${Page_0}
  ipgui::add_param $IPINST -name "C_S00_AXI_IN_HIGHADDR" -parent ${Page_0}
  ipgui::add_param $IPINST -name "C_S01_AXI_IN_BASEADDR" -parent ${Page_0}
  ipgui::add_param $IPINST -name "C_S01_AXI_IN_HIGHADDR" -parent ${Page_0}
  ipgui::add_param $IPINST -name "C_S02_AXI_IN_BASEADDR" -parent ${Page_0}
  ipgui::add_param $IPINST -name "C_S02_AXI_IN_HIGHADDR" -parent ${Page_0}


}

proc update_PARAM_VALUE.C_M_AXI_ADDR_WIDTH { PARAM_VALUE.C_M_AXI_ADDR_WIDTH } {
	# Procedure called to update C_M_AXI_ADDR_WIDTH when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_M_AXI_ADDR_WIDTH { PARAM_VALUE.C_M_AXI_ADDR_WIDTH } {
	# Procedure called to validate C_M_AXI_ADDR_WIDTH
	return true
}

proc update_PARAM_VALUE.C_M_AXI_DATA_WIDTH { PARAM_VALUE.C_M_AXI_DATA_WIDTH } {
	# Procedure called to update C_M_AXI_DATA_WIDTH when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_M_AXI_DATA_WIDTH { PARAM_VALUE.C_M_AXI_DATA_WIDTH } {
	# Procedure called to validate C_M_AXI_DATA_WIDTH
	return true
}

proc update_PARAM_VALUE.C_S00_AXI_IN_BASEADDR { PARAM_VALUE.C_S00_AXI_IN_BASEADDR } {
	# Procedure called to update C_S00_AXI_IN_BASEADDR when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_S00_AXI_IN_BASEADDR { PARAM_VALUE.C_S00_AXI_IN_BASEADDR } {
	# Procedure called to validate C_S00_AXI_IN_BASEADDR
	return true
}

proc update_PARAM_VALUE.C_S00_AXI_IN_HIGHADDR { PARAM_VALUE.C_S00_AXI_IN_HIGHADDR } {
	# Procedure called to update C_S00_AXI_IN_HIGHADDR when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_S00_AXI_IN_HIGHADDR { PARAM_VALUE.C_S00_AXI_IN_HIGHADDR } {
	# Procedure called to validate C_S00_AXI_IN_HIGHADDR
	return true
}

proc update_PARAM_VALUE.C_S01_AXI_IN_BASEADDR { PARAM_VALUE.C_S01_AXI_IN_BASEADDR } {
	# Procedure called to update C_S01_AXI_IN_BASEADDR when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_S01_AXI_IN_BASEADDR { PARAM_VALUE.C_S01_AXI_IN_BASEADDR } {
	# Procedure called to validate C_S01_AXI_IN_BASEADDR
	return true
}

proc update_PARAM_VALUE.C_S01_AXI_IN_HIGHADDR { PARAM_VALUE.C_S01_AXI_IN_HIGHADDR } {
	# Procedure called to update C_S01_AXI_IN_HIGHADDR when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_S01_AXI_IN_HIGHADDR { PARAM_VALUE.C_S01_AXI_IN_HIGHADDR } {
	# Procedure called to validate C_S01_AXI_IN_HIGHADDR
	return true
}

proc update_PARAM_VALUE.C_S02_AXI_IN_BASEADDR { PARAM_VALUE.C_S02_AXI_IN_BASEADDR } {
	# Procedure called to update C_S02_AXI_IN_BASEADDR when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_S02_AXI_IN_BASEADDR { PARAM_VALUE.C_S02_AXI_IN_BASEADDR } {
	# Procedure called to validate C_S02_AXI_IN_BASEADDR
	return true
}

proc update_PARAM_VALUE.C_S02_AXI_IN_HIGHADDR { PARAM_VALUE.C_S02_AXI_IN_HIGHADDR } {
	# Procedure called to update C_S02_AXI_IN_HIGHADDR when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_S02_AXI_IN_HIGHADDR { PARAM_VALUE.C_S02_AXI_IN_HIGHADDR } {
	# Procedure called to validate C_S02_AXI_IN_HIGHADDR
	return true
}


proc update_MODELPARAM_VALUE.C_M_AXI_ADDR_WIDTH { MODELPARAM_VALUE.C_M_AXI_ADDR_WIDTH PARAM_VALUE.C_M_AXI_ADDR_WIDTH } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_M_AXI_ADDR_WIDTH}] ${MODELPARAM_VALUE.C_M_AXI_ADDR_WIDTH}
}

proc update_MODELPARAM_VALUE.C_M_AXI_DATA_WIDTH { MODELPARAM_VALUE.C_M_AXI_DATA_WIDTH PARAM_VALUE.C_M_AXI_DATA_WIDTH } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_M_AXI_DATA_WIDTH}] ${MODELPARAM_VALUE.C_M_AXI_DATA_WIDTH}
}

