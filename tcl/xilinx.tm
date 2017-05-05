package provide odfi.hw.xilinx  1.0.0
package require odfi.common

namespace eval odfi::implementation::xilinx {

	
	## Parse an F Netlist and execute commands to add found definitions to project
	proc parseFNetlist firstFfile {

		## Recursive list
		set filesToParse {}
		lappend filesToParse $firstFfile

		## Data prepare
		set incdirs {}
		set defines {}

		## Netlist to language map
		set sources(-v2001) [list ]
		set sources(-sv) [list ]
		set sources(-vhdl) [list ]
		set sources(-xco) [list ]

		## Defaults

		# Default verilog version
		set verilogLanguage "-v2001"

		#puts "Init list of files $filesToParse"
		while {[llength $filesToParse]>0} {

			## Open File
			set ffile [odfi::common::resolveEnvVariable [lindex $filesToParse 0]]
			set fchan [open $ffile]

			# Remove gotten element from list
			set filesToParse [lreplace $filesToParse 0 0]
			#puts "List of files $filesToParse"

			# Line parsing
			##################
			while {[gets $fchan line] >= 0} {

				set line [string trim $line]
				#puts "Parsing line: $line"

				# Comment ignore
				if {[string match -nocase "#*" $line]} {

				} elseif { [string match -nocase "*.v" $line]|| [string match -nocase "*.sv" $line]} {
					
					## Verilog file
					lappend sources($verilogLanguage) [odfi::common::resolveEnvVariable $line]

				} elseif {[string match -nocase "*.vhdl" $line]|| [string match -nocase "*.vhd" $line]} {
					
					## VHDL file
					lappend sources(-vhdl) [odfi::common::resolveEnvVariable $line]

				} elseif {[string match -nocase "*.xco" $line]} {
									
					## XCO
					lappend sources(-xco) [odfi::common::resolveEnvVariable $line]
				
				} elseif {[string match -nocase "-f *" $line]} {

					## If starts with -f, then recurse

					## Recurse
					lappend filesToParse [string replace $line 0 2]

				} elseif {[string match -nocase "+incdir+*" $line]} {

					## Starts with +incdir+, it is an include directory
					regexp "\\+incdir\\+(.*)" $line -> incpath
					lappend incdirs [odfi::common::resolveEnvVariable $incpath]

				} elseif {[string match -nocase "+define+*" $line]} {

					## Starts with +define+, it is a new define
					regexp "\\+define\\+(\[A-Z_0-9\]*)" $line -> define
					lappend defines $define

				} elseif {[string match -nocase "-sv" $line]} {

					## Starts with -sv, change language to system verilog
					set verilogLanguage "-sv"

				} elseif {[string match -nocase "-sv" $line]} {

					## Starts with -sv, change language to system verilog
					set verilogLanguage "-v2001"

				}

			}

			# Close
			close $fchan
		}

		## Add results
		#######################

		#### Add incdirs
		######################
		
		#set incdirs [concat $incdirs [get_attribute hdl_search_path]]
		#set_attribute hdl_search_path $incdirs
		project set "Verilog Include Directories" [join $incdirs "|"] -process "Synthesize - XST"
		
		#foreach incDir $incdirs { 
		#}

		## Add defines string
		###########################
		set definesString ""
		foreach define $defines {
			set definesString "$definesString $define "   
		}
		set definesString "[string trim $definesString]"
		project set "Verilog Macros" $definesString -process "Synthesize - XST"
		
		#### Read Sources
		########################

		#### Verilog
		if {[llength $sources(-v2001)]>0} {

			#puts "Reading Verilog: $sources(-v2001)"
			#$cmd -v2001 -define "$definesString" $sources(-v2001)
			#xfile add $sources(-v2001) -view "Implementation" 
			foreach sfile $sources(-v2001) { 
			   xfile add $sfile -view "Implementation" 
			}
			
		}
		
		#### XCO
		if {[llength $sources(-xco)]>0} {
			foreach sfile $sources(-xco) { 
				xfile add $sfile -view "Implementation" 
			}
		}

		#### System verilog
		if {[llength $sources(-sv)]>0} {

			#$cmd -sv -define "$definesString" $sources(-sv)
		}

		#### VHDL
		if {[llength $sources(-vhdl)]>0} {
			#puts "Reading VHDL: $sources(-vhdl)"
			#$cmd -vhdl -define "$definesString" $sources(-vhdl)
		}

		#return $result
	}
	
	# Look for a $setName.tcl in :
	# - local folder
	# - Directories defined in env ODFI_HW_XILINX_PARAMETERS_SOURCES
	# Once a script is found, it is sourced and the method exits
	proc findParameters psetName {
		
		global env
		
		#### Look in local folder
		if {[file exists "./${psetName}.tcl"]} {
		
			source "./${psetName}.tcl"
			
		} elseif {[array names env "ODFI_HW_XILINX_PARAMETERS_SOURCES"]!=""} {
			#### 
			odfi::common::logWarn "Searching Parameter set $psetName into global sources"
			
			#### Split at ':'
			foreach path [split $::env(ODFI_HW_XILINX_PARAMETERS_SOURCES) :] {
				
				## If the path is not a folder, ignore
				if {[file exists $path] && [file isdirectory $path]} {
					
					## If set script exists in source folder, source and exit
					set psetScript $path/$psetName.tcl
					if {[file exists $psetScript]} {
						source $psetScript
					}
					
				} elseif {[string length $path]>0} {
					odfi::common::logWarn "Provided Parameters Set source path is not a valid folder: $path"
				}
				
			}
			
		} else {
		
			odfi::common::logWarn "Can't find parameters set script $psetName: No Parameters Sources defined"

			
		}
  
	}
		
	
}