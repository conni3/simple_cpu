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


## Order

1.  src/pc.v                //done
2.  src/imm_gen.v           //done
3.  src/control.v           //done
4.  src/alu_control.v       //done
5.  src/regfile.v           //done
6.  src/adder.v             //done
7.  src/mux2.v              //done
8.  src/alu.v               //done
9.  src/data_mem.v          //done
10. src/instr_mem.v
11. src/branch_comp.v       
12. src/cpu.v
13. tb/cpu_tb.v



## Testing

### Running simulation
```
make sim <module name>
```

`<module name>` is the name of the module, exactly how it is written in the file name.

For example, `make sim alu` would run the simulation for ALU. Leave empty to simulate all RTL blocks.

The simulations have test cases. Look for ERROR. If there is none (ideally not :D), you're good!

### Waveforms

You can also see the waveforms. Before that, make sure you have gtkwave installed. (Look at prerequisites!)

Run the command:

```
gtkwave waves/<dump_file>.vcd
```

Replace `<dump_file>.vcd` with any of the module names (`regfile`, `pc`, etc). You can use `all` to select all the modules.