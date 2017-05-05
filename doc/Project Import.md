Vivado Project Import
============================


# Import an FFile inside Vivado

Example:


    ## Load packages (will be simplified)
    ###################
    catch {
        package forget  odfi::implementation::xilinx::vivado
        package forget  odfi::dev::hw::netlist 
    }
    package require odfi::implementation::xilinx::vivado
    package require odfi::dev::hw::netlist 


    ## Import FFile
    #######################
    vivado::importFFile path/to/ffile.f
