# Vivado TCL script to synthesize design and produce various reports
# Usage: vivado -mode batch -source scripts/reports.tcl -tclargs <part> <top> <incdir> <src ...>

set part    [lindex $argv 0]
set top     [lindex $argv 1]
set incdir  [lindex $argv 2]
set sources [lrange $argv 3 end]

if { $part eq "" || $top eq "" || $incdir eq "" || [llength $sources] == 0 } {
    puts "Usage: vivado -mode batch -source scripts/reports.tcl -tclargs <part> <top> <incdir> <src ...>"
    exit 1
}

# Read all source files, supplying the include directory
set_property include_dirs $incdir [current_fileset]
read_verilog -sv $sources

# Run project-less out-of-context synthesis
synth_design -top $top -part $part -mode out_of_context

# Emit reports
# report_synth -file logs/synth.rpt 
report_timing_summary   -file logs/timing_summary.rpt
report_clock_networks   -file logs/clock_networks.rpt
report_clock_interaction -file logs/clock_interaction.rpt
report_methodology      -file logs/methodology.rpt
report_drc              -file logs/drc.rpt
# report_noise            -file logs/noise.rpt
report_utilization      -file logs/utilization.rpt
report_power            -file logs/power.rpt

exit
