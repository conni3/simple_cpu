# RISC-V Test Programs

This directory contains small RISC-V assembly programs used by the
Verilog testbenches.  Each program assembles into a memory initialization
file (`*.mem`) containing one 32-bit little-endian word per line.

## Regenerating

Install a RISC-V GCC toolchain in your `PATH` and run:

```
make
```

The `Makefile` assembles each `.S` file, converts the ELF to raw binary,
and formats it into the required hex representation.

Each program stores the status pass code (`STATUS_PASS`, default
`0xC0DECAFE`) to address `STATUS_ADDR` (default `0x00000000`) and
ends with `0000006F` (`jal x0,0`) so the CPU testbench can detect
completion.
