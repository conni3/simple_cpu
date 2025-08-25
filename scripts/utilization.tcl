# Vivado TCL script to synthesize design and produce a utilization report
# Usage: vivado -mode batch -source scripts/utilization.tcl -tclargs <part> <top> <incdir> <src ...>

set part    [lindex $argv 0]
set top     [lindex $argv 1]
set incdir  [lindex $argv 2]
set sources [lrange $argv 3 end]

if { $part eq "" || $top eq "" || $incdir eq "" || [llength $sources] == 0 } {
    puts "Usage: vivado -mode batch -source scripts/utilization.tcl -tclargs <part> <top> <incdir> <src ...>"
    exit 1
}

# Read all source files, supplying the include directory so that
# `\`include` directives resolve correctly
set_property include_dirs $incdir [current_fileset]
read_verilog -sv $sources

# Run synthesis and emit utilization report
synth_design -top $top -part $part
report_utilization -file logs/utilization.rpt
exit
