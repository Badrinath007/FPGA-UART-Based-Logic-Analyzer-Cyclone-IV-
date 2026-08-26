# FPGA-Based Logic Analyzer — Cyclone IV (EP4CE)

A hardware logic analyzer implemented in RTL Verilog on an Intel Cyclone IV FPGA. Designed as a low-cost, open alternative to commercial tools like SignalTap and Xilinx ILA — with real-time signal capture, trigger-based acquisition, UART streaming, and waveform visualization via GTKWave.

> Built to explore signal capture and debugging without access to expensive lab equipment.

---

## Key Highlights

| Parameter | Value |
|---|---|
| Platform | Intel Cyclone IV (EP4CE6E22C8N) |
| Target Clock | 25 MHz (design intent, not timing-closure-verified) |
| Interface | UART (hardware UART — no soft IP) |
| Waveform Output | VCD → GTKWave / Modelsim |
| RTL Language | Verilog |
| Toolchain | Quartus Prime, GTKWave, Python 3, Modelsim |

---

## Architecture

```
Signal Input → Circular Buffer (RTL) → Trigger/Capture Control Logic → UART TX → Python Host → VCD → GTKWave
```

### RTL Design Blocks

- **Circular Buffer** — Continuous signal capture using a ring buffer with configurable depth (parameterized `DEPTH`). Intended to allow pre-trigger and post-trigger data retention.
- **Capture Control Logic** — Flag-based control (`capturing`, `triggered`, `sending`) that monitors incoming signal for a user-defined trigger value, then captures a fixed post-trigger window before halting. Note: this is implemented as flag-driven sequential logic, not a formally encoded state machine.
- **UART Transmitter** — Streams captured buffer contents serially to the host machine.
- **Python Host Script** — Receives UART data, reconstructs sample timing, and generates a `.vcd` file.

---

## Waveform Output

Sample waveform from GTKWave:

![Waveform Output](https://github.com/user-attachments/assets/2fe5ecb3-c28e-495e-900f-49349c2f585c)

---

## Design Decisions & Engineering Rationale

**Why a circular buffer?**
A circular buffer allows continuous capture without stalling the signal pipeline, with the intent of preserving pre-trigger data for debugging transient conditions.

**Why UART instead of JTAG/USB-FIFO?**
UART keeps the BOM cost at zero — any CP2102 or CH340 USB-UART adapter works. The tradeoff is bandwidth.

**Why Python for VCD generation?**
VCD is a text-based format — Python handles the byte-to-sample reconstruction and file generation with no external dependencies.

---

## Known Limitations / Not Yet Verified

- **No SDC constraint file or TimeQuest timing report is currently committed to this repo.** The 25MHz target reflects design intent based on UART bandwidth, not a closed/verified timing analysis. This is the top open item for the project.
- The capture control logic is flag-based, not a formally encoded FSM — state encoding and transition diagrams are not yet documented.
- No overflow/re-arm protection is implemented if the trigger condition isn't met before the write pointer wraps around.
- Read-pointer offset logic (`rd_ptr <= wr_ptr + 1` at trigger) has not been independently verified against expected chronological ordering.

---

## Repository Structure

```
├── docs/
│   ├── waveform.png            # Output Waveform
├── python/
│   └── capture.py              # UART capture + VCD generation script
├── rtl/
│   |── logic_analyzer.v
|   |── top.v                   # Top-level module
|   |── uart_tx.v                # UART transmitter (8N1)
└── README.md
```

---

## How to Run

### FPGA Build
```bash
# Open in Quartus Prime
# Compile project — target: Cyclone IV EP4CE
# Program board via JTAG using Quartus Programmer/openFPGA Loader
```

### Host Capture
```bash
python3 python/capture.py --port /dev/ttyUSB0 --baud 115200
gtkwave wave.vcd
```

---

## What This Project Demonstrates

- **RTL Design** — Synthesizable Verilog with sequential control logic, memory structures, and a serial interface
- **Hardware-Software Integration** — FPGA RTL interfacing with a Python host over physical UART
- **Hardware Bring-Up (Partial)** — Design was synthesized and programmed onto a physical Cyclone IV board and UART communication with the host was exercised on-device. Timing closure was not verified (see Known Limitations) and the core buffer/trigger logic's correctness has not been independently confirmed on hardware — this project is not yet claimed as fully hardware-verified.

---

## Motivation

Commercial logic analyzers (SignalTap, Xilinx ILA) require tool-specific integration and consume FPGA fabric. This project explores an equivalent capture-and-stream architecture in RTL, portable across any FPGA with a UART-capable pin.

---

## Tools & Environment

| Tool | Purpose |
|---|---|
| Quartus Prime | Synthesis, P&R, Programming |
| GTKWave | Waveform Visualization |
| Python 3 | Host capture + VCD generation |
| Icarus Verilog | RTL Simulation (pre-synthesis) |
| CuteCom | UART terminal for debug |

---

## Author

**Badrinath Ayyamperumal**
ECE Graduate — Anna University (BIT Campus, Tiruchirappalli) — 2023
RTL Design | FPGA Prototyping | Hardware Bringup

[![LinkedIn](https://img.shields.io/badge/LinkedIn-Connect-blue)](https://linkedin.com/in/badrinatha)
[![GitHub](https://img.shields.io/badge/GitHub-Profile-black)](https://github.com/Badrinath007)
