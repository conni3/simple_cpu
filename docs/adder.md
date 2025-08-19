
# Entity: adder 
- **File**: adder.v

## Diagram
![Diagram](adder.svg "Diagram")
## Generics

| Generic name | Type | Value | Description |
| ------------ | ---- | ----- | ----------- |
| WIDTH        | int  | 32    |             |

## Ports

| Port name | Direction | Type             | Description |
| --------- | --------- | ---------------- | ----------- |
| a         | input     | wire [WIDTH-1:0] |             |
| b         | input     | wire [WIDTH-1:0] |             |
| result    | output    | wire [WIDTH-1:0] |             |
