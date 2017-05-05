package provide odfi::implementation::xilinx::vivado 1.0.0 
package require odfi::dev::hw::netlist
package require odfi::list 2.0.0
package require odfi::files 1.0.0

namespace eval vivado {

    odfi::common::resetNamespaceClasses [namespace current]

    ## @param path Path to a F File
    proc importFFile path {

        ## Parse 
        ##############
        set fFile [odfi::dev::hw::netlist::createFFile $path]

        puts "statistics:"
        $fFile statistics

        ## Import 
        ###############

        ## Add source
        $fFile eachSource {
            ::add_files $it
        }

        ## Add include directories
        $fFile eachIncdir {
            puts "ADDING INCDIR $it"
            ::add_files -scan_for_includes $it
        }


        ## Defines
        odfi::files::writeToFile "test.h" "`define SIZE 12"
        ::add_files -scan_for_includes "test.h"

        ## Set modes
        ####################
        ::set_property source_mgmt_mode All [::current_project]

    }

}
