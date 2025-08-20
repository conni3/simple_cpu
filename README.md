# Usage

## 0) Prerequisites

* **Icarus Verilog** (`iverilog`, `vvp`)
* **GTKWave** (`gtkwave`) for waveforms
* (Optional) **Vivado XSIM** (`xvlog`, `xelab`, `xsim`)

  * Default Vivado settings file is `VIVADO_SETTINGS=/opt/Xilinx/Vivado/2025.1/2025.1/Vivado/settings64.sh`
  * Override if yours differs:
    `make vivado comp=foo VIVADO_VERSION=2024.2 VIVADO_SETTINGS=/path/to/settings64.sh`
* (Optional) **Schematic rendering**:

  * `yosys`, `jq`, `netlistsvg`

Project layout:

```
include/        // headers (e.g., defines.vh)
src/leaf/       // leaf RTL modules
src/glue/       // small glue/adapter modules
src/top/        // top/wrappers
tb/             // testbenches named <module>_tb.v
images/         // rendered schematics (.svg)
.build/         // compiled outputs (auto-created)
waves/          // VCDs (auto-created)
```

> Testbenches must be named `tb/<name>_tb.v`. The Makefile discovers them automatically.

---

## 1) Quick start (run everything with Icarus)

```bash
make           # same as: make test
```

* Lints, compiles, runs all `tb/*_tb.v`.
* Dumps VCDs per testbench to `waves/<name>.vcd` (if your TB calls `$dumpfile("dump.vcd")`).

---

## 2) Work on a single testbench

Pick the `comp` name (prefix of `_tb.v`).

**Lint**

```bash
make check comp=alu_control
```

**Compile**

```bash
make build comp=alu_control
# Output: .build/alu_control.vvp
```

**Run**

```bash
make run comp=alu_control
# or: make test comp=alu_control
```

**Open waveform**

```bash
make wave comp=alu_control
# opens waves/alu_control.vcd in GTKWave (if your TB produced dump.vcd)
```

---

## 3) Vivado XSIM (optional)

Run a single testbench with XSIM:

```bash
make vivado comp=alu_control
```

Run all testbenches with XSIM:

```bash
make vivado-all
```

> If Vivado is installed in a different location/version, override:

```bash
make vivado comp=alu_control VIVADO_SETTINGS=/path/to/settings64.sh
# or:
make vivado comp=alu_control VIVADO_VERSION=2024.2 VIVADO_SETTINGS=/opt/Xilinx/Vivado/2024.2/2024.2/Vivado/settings64.sh
```

---

## 4) Generate schematics (per‑module)

List modules Yosys sees:

```bash
make mods
```

Render **all** modules to `images/*.svg`:

```bash
make schem
```

Render a **specific** top:

```bash
make schem-top comp=cpu
# outputs: images/cpu.svg
```

Clean schematic artifacts:

```bash
make schem-clean
```

---

## 5) Clean builds/logs

```bash
make clean
```

Removes `.build/`, `waves/`, sim artifacts, XSIM junk, etc.

---

## 6) Tips & conventions

* Include path `include/` is already passed (`-I include`), so headers like `` `include "defines.vh"`` work.
* Each TB should create a VCD like this:

  ```verilog
  initial begin
    $dumpfile("dump.vcd");
    $dumpvars(0, <top_of_tb_or_dut>);
  end
  ```

  The Makefile will rename `dump.vcd` to `waves/<tbname>.vcd` automatically.
* To add a new TB `tb/<name>_tb.v`, you don’t need to edit the Makefile. It will be discovered:

  * Run all: `make`
  * Single: `make test comp=<name>`
* If you see **“No such command”** when running `schem-top`, ensure `yosys`, `jq`, and `netlistsvg` are in `PATH`.
* If Vivado **xvlog/xelab/xsim** fail to start, verify your `settings64.sh` path and try again with explicit `VIVADO_SETTINGS=...`.

---

## 7) Common problems

**Q: My VCD is missing.**
A: Confirm your TB calls `$dumpfile("dump.vcd")` **and** `$dumpvars(...)`. Without those, no waveform will be produced.

**Q: XSIM says snapshot not found.**
A: That flow uses:

1. `xvlog` (compile)
2. `xelab -snapshot <name>_sim work.<name>_tb` (elab)
3. `xsim <name>_sim --runall` (run)
   Make sure `comp=<name>` matches the TB filename prefix and that `xvlog` succeeded.

**Q: `@* is sensitive to all words in array` in Icarus.**
A: That’s a harmless warning for combinational reads from a `reg [ ] mem [ ]`. You can ignore it for simple sims.


