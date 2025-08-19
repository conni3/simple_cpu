# run.py  (place at repo root)
from pathlib import Path
from vunit import VUnit

ROOT = Path(__file__).parent
INC  = [str(ROOT / "include")]  # where your .vh lives

vu = VUnit.from_argv()
vu.add_verilog_builtins()  # provides vunit_defines.svh if you use SV tests

lib = vu.add_library("lib")


# Design files
lib.add_source_files(str(ROOT / "src/**/*.v"), include_dirs=INC)

# Testbenches (optional)
lib.add_source_files(str(ROOT / "tb/**/*_tb.v"), include_dirs=INC, allow_empty=True)

if __name__ == "__main__":
    vu.main()
