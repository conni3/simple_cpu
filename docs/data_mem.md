
# Entity: data_mem 
- **File**: data_mem.v

## Diagram
![Diagram](../images/docs/data_mem.svg "Diagram")

## Schematic
![Schematic](../images/schematics/data_mem.svg "Schematic")
## Ports

| Port name  | Direction | Type        | Description |
| ---------- | --------- | ----------- | ----------- |
| clk        | input     | wire        | Clock for synchronous writes |
| we         | input     | wire        | Write enable |
| re         | input     | wire        | Read enable |
| addr       | input     | wire [10:0] | Word address within memory |
| write_data | input     | wire [31:0] | Data to be written |
| read_data  | output    | wire [31:0] | Data read from memory |

## Signals

| Name             | Type       | Description |
| ---------------- | ---------- | ----------- |
| mem[(1<<11)-1:0] | reg [31:0] | 2^11 words of 32‑bit memory |

## Processes
- unnamed: ( @(posedge clk) )
  - **Type:** always

## Behavior
Implements a simple 32‑bit data memory with synchronous writes and combinational reads controlled by `we`/`re`.

> **Note:** Only word-aligned load and store operations are supported. Byte or half‑word accesses and their accompanying sign‑extension logic are not implemented.
