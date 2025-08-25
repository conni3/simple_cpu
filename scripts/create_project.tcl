# scripts/create_project.tcl
# Usage:
#   vivado -mode batch -nojournal -nolog -notrace \
#     -source scripts/create_project.tcl \
#     -tclargs <PART> <TOP> <file1> <file2> ...

if {$argc < 2} {
  puts "Usage: -tclargs <PART> <TOP> <file1> <file2> ..."
  exit 2
}

set part  [lindex $argv 0]
set top   [lindex $argv 1]
set files [lrange $argv 2 end]

create_project simple_cpu ./vivado_proj -part $part -force

# Collect and normalize files passed from Make
set to_add {}
foreach f $files {
  if {[file exists $f]} {
    lappend to_add [file normalize $f]
  } else {
    puts "WARN: missing file: $f"
  }
}

if {[llength $to_add] == 0} {
  puts "ERROR: no source files provided"
  exit 3
}

# Add to both sources_1 and sim_1 so xsim sees TBs
add_files -fileset sources_1 $to_add
add_files -fileset sim_1     $to_add

set incdir [file normalize "./include"]
set_property include_dirs $incdir [get_filesets sources_1]
set_property include_dirs $incdir [get_filesets sim_1]


# Set simulation top (keep synth top unset unless you really synthesize the TB)
set_property top $top [get_filesets sim_1]

# Recompute orders
update_compile_order -fileset sources_1
update_compile_order -fileset sim_1

