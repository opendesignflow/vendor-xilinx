###############################
## Init Project is called after project creation to set base parameters
################################

## Device
######################################

project set "family"                "Virtex6"
project set "device"                "xc6vlx240t"
project set "package"               "ff1759"
project set "speed"                 "-2"

## Language
######################################
project set "Preferred Language"    "verilog"
project set "Verilog 2001 Xst"      "true"


## Parameters set for Extoll R2 64
##############################################
source ise_parameters_extoll_r2_64.tcl

## Generate PFlash programming file
##############################################
