
# Entity: adder 
- **File**: adder.v

## Diagram
![Diagram](adder.svg "Diagram")
## Generics

| Generic name | Type | Value | Description |
| ------------ | ---- | ----- | ----------- |
| WIDTH        | int  | 32    | Bit-width of inputs and result |

## Ports

| Port name | Direction | Type             | Description |
| --------- | --------- | ---------------- | ----------- |
| a         | input     | wire [WIDTH-1:0] | First addend |
| b         | input     | wire [WIDTH-1:0] | Second addend |
| result    | output    | wire [WIDTH-1:0] | Sum of `a` and `b` |

## Behavior
Adds the two `WIDTH`‑bit operands and drives their `WIDTH`‑bit sum on `result`.
