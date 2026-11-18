set service_port 33581
set listen_address 127.0.0.1

namespace eval vjtag {
	variable tap
}

set ::vjtag::devices {
	# GW2AR-18 on TangNano 20k
	{ 0x0000081b 0x42 0x43 GW2AR }
	
	# ECP5 LFE5U25 on IceSugarPro
	{ 0x41111043 0x32 0x38 ECP5 }

	# ECP5 LFE5U45 on ULX3S
	{ 0x41112043 0x32 0x38 ECP5 }

	# ECP5 LFE5U85 on ULX3S
	{ 0x41113043 0x32 0x38 ECP5 }
	
	# ECP5 LFE5UM85 on MMM-V4R0-L5SD
	{ 0x01113043 0x32 0x38 ECP5 }

	# XC3S1600 on PanoLogic G1
	{ 0x21c3a093 0x02 0x03 {Spartan 3E}}

}


# Virtual IR scan
proc ::vjtag::ir {ir} {
	irscan $::vjtag::tap $::vjtag::vir
	return [drscan $::vjtag::tap 32 $ir]
}


# Virtual DR scan - shifts a value into a register attached to ER2
proc ::vjtag::dr {v} {
	irscan $::vjtag::tap $::vjtag::vdr
	return [drscan $::vjtag::tap 32 $v]
}

# Convert decimal number to the required binary code
proc ::vjtag::dec2bin {i {width {}}} {

    set res {}
    if {$i<0} {
        set sign -
        set i [expr {abs($i)}]
    } else {
        set sign {}
    }
    while {$i>0} {
        set res [expr {$i%2}]$res
        set i [expr {$i/2}]
    }
    if {$res == {}} {set res 0}

    if {$width != {}} {
        append d [string repeat 0 $width] $res
        set res [string range $d [string length $res] end]
    }
    return $sign$res
}

# Convert a binary string to a decimal/ascii number
proc ::vjtag::bin2dec {bin} {
    if {$bin == 0} {
        return 0
    } elseif {[string match -* $bin]} {
        set sign -
        set bin [string range $bin[set bin {}] 1 end]
    } else {
        set sign {}
    }
    return $sign[expr 0b$bin]
}

proc ::vjtag::recv {} {
	if {[expr [::vjtag::ir 0] & 1]} {
		return -1
	}
	return [::vjtag::dr 0]
}

proc ::vjtag::recv_blocking {} {
	set s [::vjtag::ir 0]
#	puts "recv_blocking: $s"
	while {[expr {[expr 0x$s] & 1}]} {
		set s [::vjtag::ir 0]
	}
#	puts "ok"
	return [::vjtag::dr 0]
}

proc ::vjtag::send {a} {
	set s [::vjtag::ir 0x00]
	while {[expr {[expr 0x$s] & 8}]} {
#		puts "Fifo full"
		after 10
		set s [::vjtag::ir 0x00]
	}
	::vjtag::ir 0x01
	::vjtag::dr $a
}


init
scan_chain
set ::vjtag::tap target.tap

# Determine Usr1 and Usr2 JTAG IR scan codes for the current device
set id [jtag cget $::vjtag::tap -idcode]

set v -1
for {set i 0} {$i < [llength $::vjtag::devices]} {incr i} {
	set record [lindex $::vjtag::devices $i]
	if {[lindex $record 0] == $id} {
		set ::vjtag::vir [lindex $record 1]
		set ::vjtag::vdr [lindex $record 2]
		puts "[lindex $record 3] found - vir $::vjtag::vir, vdr $::vjtag::vdr"
		set v $i
	}
}


# Make the script interruptable with ctrl-c (FIXME - doesn't work once the server is active.)
signal handle SIGINT SIGTERM
catch -signal {
	exit
}

set f [socket stream.server $service_port]
$f readable {
    set client [$f accept]
	fconfigure $client -translation binary -buffering none -blocking true
    puts "Connection accepted"

	set portopen 0
	
	while {1} {
		set cmd [read $client 1]
		set parambytes [read $client 1]
		set responsebytes [read $client 1]
		set byteparam [read $client 1]
		if {[eof $client]} {
			break
		}
		set numchars [string length $byteparam]
#		puts "numchars $numchars"
		# Did we receive something?
		if { $numchars > 0 } {

			scan $cmd %c ascii

			if { $ascii == 255} {
				puts -nonewline $client [format %c $portopen]
				# Release the USB blaster again
#				if { $portopen == 1 } { vjtag::usbblaster_close  }
				set portopen 0
			}
			
			if { $ascii != 255} {
				if { $portopen == 0 } {
#					if [ vjtag::usbblaster_open ] { set portopen 1 }
					set portopen 1
				}

				set cmd [expr {$ascii << 24}]
				scan $parambytes %c parambytes
				set cmd [expr {$cmd | [expr {$parambytes << 16}]}]
				scan $responsebytes %c responsebytes
				set cmd [expr {$cmd | [expr {$responsebytes << 8}]}]
				scan $byteparam %c byteparam
				set cmd [expr {$cmd | $byteparam}]
#				puts "[vjtag::dec2bin $cmd 32]"
#				puts "Sending [format %x $cmd]"
				::vjtag::send $cmd

				# Sending parameters, if any

				set cmd 0
				while { $parambytes > 0 } {
					set byteparam [read $client 1]
					scan $byteparam %c ascii
					set cmd [expr {[expr {$cmd << 8}] | $ascii}]
					set parambytes [expr {$parambytes - 1}]
					if {$parambytes==0 || $parambytes==4} {
#						puts "Sending [format %x $cmd]"
	#					puts "[vjtag::dec2bin $cmd 32]"
						::vjtag::send $cmd
						set cmd 0
					}
				}

				while { $responsebytes > 0 } {
#					puts "Fetching $responsebytes response bytes"
					if {[eof $client]} break
					set rx 0
					set rx [::vjtag::recv_blocking]
					set rx [expr 0x$rx]
					puts -nonewline $client [format %c [expr {[expr {$rx >> 24}] & 255}]]
					puts -nonewline $client [format %c [expr {[expr {$rx >> 16}] & 255}]]
					puts -nonewline $client [format %c [expr {[expr {$rx >> 8}] & 255}]]
					puts -nonewline $client [format %c [expr {$rx & 255}]]
					set responsebytes [expr {$responsebytes -4}]
				}
			}
		}
	}
	puts "Connection terminated"
    $client close
   	exit
}
vwait done
exit

