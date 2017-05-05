

catch {
    package forget  odfi::implementation::xilinx::vivado
    package forget  odfi::dev::hw::netlist 
}
package require odfi::implementation::xilinx::vivado
package require odfi::dev::hw::netlist 


## Parse FFile
#######################

#set fFile [edid::netlist::createFFile  ./top.f]

#$fFile statistics

puts "Hello world"

vivado::importFFile top.f


save_project_as -force test.pro

update_compile_order


#set_property top a [::current_project]
synth_design -rtl
