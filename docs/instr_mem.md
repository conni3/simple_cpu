
# Entity: instr_mem 
- **File**: instr_mem.v

## Diagram
![Diagram](instr_mem.svg "Diagram")
## Ports

| Port name | Direction | Type        | Description |
| --------- | --------- | ----------- | ----------- |
| addr      | input     | wire [10:0] |             |
| instr     | output    | [31:0]      |             |

## Signals

| Name             | Type       | Description |
| ---------------- | ---------- | ----------- |
| mem[0:(1<<11)-1] | reg [31:0] |             |

## Processes
- unnamed: ( @(*) )
  - **Type:** always
