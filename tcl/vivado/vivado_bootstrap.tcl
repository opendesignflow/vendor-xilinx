
###################
## Load Packages 
####################
proc ::reloadEnvironment args {

    catch {
        package forget  odfi::implementation::xilinx::vivado
        package forget  odfi::dev::hw::netlist 
    }
    package require odfi::implementation::xilinx::vivado
    package require odfi::dev::hw::netlist 
    
}

reloadEnvironment
