#####################################################
#####################################################
## Parameters Set for Extoll R2 64 implementation  ##
#####################################################
#####################################################


## XST
##################################
project set "Optimization Effort"           "High"                                  -process "Synthesize - XST"
project set "Netlist Hierarchy"             "Rebuilt"                               -process "Synthesize - XST"


## Translate
####################################


## MAP
####################################
project set "Allow Logic Optimization Across Hierarchy" "TRUE"                      -process "Map"
project set "Combinatorial Logic Optimization"          "TRUE"                      -process "Map"
project set "Global Optimization"                       "Speed"                     -process "Map"
project set "Placer Effort Level"                       "High"                      -process "Map"
project set "Placer Extra Effort"                       "Continue on Impossible"    -process "Map"

project set "Register Duplication"                      "On"                        -process "Map"
project set "Retiming"                                  "false"                     -process "Map"

# Off or "2"
project set "Enable Multi-Threading"                    "off"                       -process "Map"

## Place and route "Place & Route"
#####################################

project set "Extra Effort (Highest PAR level only)"     "Continue on Impossible"    -process "Place & Route"
project set "Place & Route Effort Level (Overall)"      "High"                      -process "Place & Route"

#"Off", "2", "3", "4" 
project set "Enable Multi-Threading"                    "2"                         -process "Place & Route"
