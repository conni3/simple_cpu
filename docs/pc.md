
# Entity: pc 
- **File**: pc.v

## Diagram
![Diagram](../images/docs/pc.svg "Diagram")

## Schematic
![Schematic](../images/schematics/pc.svg "Schematic")
## Ports

| Port name  | Direction | Type        | Description |
| ---------- | --------- | ----------- | ----------- |
| clk        | input     | wire        | Clock input |
| reset      | input     | wire        | Asynchronous reset |
| next_pc    | input     | wire [31:0] | Next program counter value |
| current_pc | output    | wire [31:0] | Current program counter |

## Processes
- unnamed: ( @(posedge clk or posedge reset) )
  - **Type:** always

## Behavior
Stores the current program counter; on reset sets PC to 0, otherwise loads `next_pc` on each rising clock edge.
