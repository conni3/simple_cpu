## Project structure

```project/
├── src/
│   ├── cpu.v              // top-level
│   ├── pc.v
│   ├── instr_mem.v        // thin wrapper around BRAM IP
│   ├── regfile.v
│   ├── control.v
│   ├── alu_control.v
│   ├── alu.v
│   ├── data_mem.v
│   ├── imm_gen.v
│   ├── mux2.v
│   └── adder.v
├── tb/
│   └── cpu_tb.v
├── coe/
│   └── instr_mem.coe
└── build/
    └── cpu_design.tcl

```

### Fetch

1. Instr_mem
2. pc
3. pc mux

### Decode

1. control unit
2. imm_gen
3. rs1/rs2

### Execute

1. ALU
2. ALUcontrol
3. branch_comp
4. branch arithmetics

### Memory

1. Data memory

### Write-back

1. Regfile

## Testing

### Running simulation

```
make sim comp=<module name>
```

`<module name>` is the name of the module, exactly how it is written in the file name.

For example, `make sim alu` would run the simulation for ALU. Leave empty to simulate all RTL blocks. (`make sim`)

The simulations have test cases. Look for ERROR. If there is none (ideally not :D), you're good!

### Waveforms

You can also see the waveforms. Before that, make sure you have gtkwave installed. (Look at prerequisites!)

Run the command:

```
gtkwave waves/<dump_file>.vcd
```

Replace `<dump_file>.vcd` with any of the module names (`regfile`, `pc`, etc). You can use `all` to select all the modules.
