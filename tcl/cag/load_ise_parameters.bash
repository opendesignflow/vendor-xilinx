#!/bin/bash

# Source this script to add path to look for ISE parameters scripts
export ODFI_HW_XILINX_PARAMETERS_SOURCES=$ODFI_HW_XILINX_PARAMETERS_SOURCES:"$(dirname "$(readlink -f ${BASH_SOURCE[0]})")" 