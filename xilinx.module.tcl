
:name set "xilinx"


:command ise {

	:log:info "Running ISE...[lindex $args 0]"

	set ise [:runCommandGet find-ise]

	set startExe $ise/ISE/bin/nt64/ise.exe 

	exec $startExe [lindex $args 0] >@stdout <@stdin 2>@1

}

:command isesh {

	:log:info "Running ISE TCLSH..."

	set ise [:runCommandGet find-ise]

	set startExe $ise/ISE/bin/nt64/xtclsh.exe 

	exec $startExe >@stdout <@stdin 2>@1

}

:command list-ise {


	:log:info "Listing ISE...."
	set foundISE [glob -nocomplain -join -types d -directory C:/Xilinx/ \[0-9\]*.\[0-9\]* ISE_DS]

	foreach iseDir $foundISE {
		:log:info "Listing ISE.... $iseDir"
	}

	${:commandResult} set $foundISE

}

:command find-ise {


	set ise [:runCommandGet "list-ise"]

	if {[llength $ise]==0} {

		:log:error "Cannot run ISE script, no ISE detected...."

	} else {

		${:commandResult} set [lindex $ise 0]
	}

}


puts "Loading XILINX"
:fileCommandHandler tcl-ise {
    
    :priority set 10

    :log:setPrefix odfi.FCH.ISE

    :onAccept {
    
        if {[$cmd isTCL] && [$cmd testExtensions "ise.tcl" ] } {
            return 10
        } else {
            return false
        }
        
    }
    
    :onRun {
    
    	:log:info "Running XILINX script....[$cmd path get]"


    	set ise [:runCommandGet "list-ise"]

    	if {[llength $ise]==0} {

    		:log:error "Cannot run ISE script, no ISE detected...."

		} else {

			set iseDir [lindex $ise 0]

			:log:info "Found ISE at: $iseDir"

			## Get Interpreter Path
			set interpreterCommand [file normalize $iseDir/ISE/bin/nt64/xtclsh.exe]
			:log:info "Interpreter at: $interpreterCommand"

			## Prepare Environment
        	set runEnv [[:getODFI] env:environment]
        	set tcllibenv {}

        	[$runEnv shade ::odfi::environment::PreScript children] @> filter { return [string match "*.tcl" [$it path get]] } @> foreach {
			
        		lappend tcllibenv [file dirname [$it path get]]
        	}

        	:log:info "Actual path: [info library]"
        	#:log:info "ENV: $tcllibenv"

        	## Running 
        	#set env(TCLLIBPATH) [join $tcllibenv] 

        	#exec env TCLLIBPATH=$tcllibenv $interpreterCommand [$cmd path get] >@stdout <@stdin 2>@1
        	exec env TCLLIBPATH=$tcllibenv $interpreterCommand [$cmd path get] >@stdout <@stdin 2>@1
        	#::odfi::powerbuild::exec $interpreterCommand [$cmd path get]

		}


    	return


        ## Create Environment
        set runEnv [[:getODFI] env:environment]
        
        ## Create Interpreter
        puts "Creating slave interpreter"
        set runInterpreter [interp create]
        puts "Interp name: $runInterpreter"
        #interp hide $runInterpreter open open
       #interp hide $runInterpreter puts puts
        #$runInterpreter alias open ::open
        #$runInterpreter alias puts ::puts
        
        ## Source prescripts
        #set foundDevTCL false
        #puts "Prescripts: [[$runEnv shade ::odfi::environment::PreScript firstChild]  path get]"
        [$runEnv shade ::odfi::environment::PreScript children] @> filter { return [string match "*.tcl" [$it path get]] } @> foreach {
             #puts "Sourcing prescript [$it path get]" 
            $runInterpreter eval [list source [$it path get]]
            #if {[string match "*tcl/devlib*"  [$it path get]]} {
            #    set foundDevTCL true
            #}
        }
        
        ## If devlib was not found; set the internal one
        #if {!$foundDevTCL} {
            #puts "Loading internal dev-tcl"
            #$runInterpreter eval [list source ${::odfi::moduleLocation}/odfi-dev-tcl/tcl/pkgIndex.tcl]
        #}
        
        ## Make Sure NX can be found
        if {![catch {set ::nxLocalPath}]} {
            if {${::nxLocalPath}!="" && [file isfile ${::nxLocalPath}]} {
                puts "Loading local NX -> ${::nxLocalPath}"
                $runInterpreter eval [list set dir [file dirname ${::nxLocalPath}]]
                $runInterpreter eval [list source ${::nxLocalPath}]
            }
            
        }
        #if {${::nxLocalPath}!=""} {
        #    #puts "Loading local NX -> ${::nxLocalPath}"
        #    $runInterpreter eval [list set dir [file dirname ${::nxLocalPath}]]
        #    $runInterpreter eval [list source ${::nxLocalPath}]
        #}
        
        
        ## Source script in interpreter then delete
        try {
            
            $runInterpreter eval [list set argv [join [lrange $args 1 end]]]
            $runInterpreter eval [list source [$cmd path get]]
        
        } finally {
            interp delete $runInterpreter
        }
    }
}

