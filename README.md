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
│   ├── sign_extend.v
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

1. src/pc.v         //done
2. src/alu.v        //done
3. src/regfile.v    //done
4. src/immgen.v
5. src/control.v
6. src/dmem.v
7. src/imem.v
8. src/branch_comp.v
9. src/cpu.v
10. tb/cpu_tb.v


## Testing

```
make sim <module name>
```

`<module name>` is the name of the module, exactly how it is written in the file name.

For example, `make sim alu` would run the simulation for ALU.