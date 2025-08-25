# Vivado TCL script to synthesize design and produce a utilization report
# Usage: vivado -mode batch -source scripts/utilization.tcl -tclargs <part> <top> <src ...>

set part [lindex $argv 0]
set top  [lindex $argv 1]
set sources [lrange $argv 2 end]

if { $part eq "" || $top eq "" || [llength $sources] == 0 } {
    puts "Usage: vivado -mode batch -source scripts/utilization.tcl -tclargs <part> <top> <src ...>"
    exit 1
}

# Read all source files
foreach f $sources {
    read_verilog $f
}

# Run synthesis and emit utilization report
synth_design -top $top -part $part
report_utilization -file logs/utilization.rpt
exit
