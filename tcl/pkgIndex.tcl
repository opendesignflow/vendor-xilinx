
set dir [file dirname [file normalize [info script]]]

# base package
package ifneeded odfi.hw.xilinx 1.0.0 [list source [file join $dir xilinx.tm]]



#package ifneeded odfi::implementation::xilinx::vivado 1.0.0 [list \
#        [list load [list $dir/vivado/libitcl3.4.so Itcl]] \
#        puts "Loaded TCL lib" \
#        source [file join $dir vivado vivado-1.0.0.tm] \
#        ]
#load    $dir/vivado/libitcl3.4.so Itcl
package ifneeded odfi::implementation::xilinx::vivado 1.0.0 "
    puts \"TCL version: [info tclversion]\"
    puts \"TCL version: [info script]\"
    #upvar $dir dir
    puts \"Hello $dir\"
    array set env {ITCL_LIBRARY $dir/vivado}
    load $dir/vivado/libitcl3.4.so Itcl
    source [file join $dir vivado vivado-1.0.0.tm]
"
