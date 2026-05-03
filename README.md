# FPGA-Based Logic Analyzer — Cyclone IV (EP4CE)

A hardware logic analyzer implemented entirely in RTL Verilog on an Intel Cyclone IV FPGA. Designed as a low-cost, open alternative to commercial tools like SignalTap and Xilinx ILA — with real-time signal capture, trigger-based acquisition, UART streaming, and waveform visualization via GTKWave.

> Built to solve a real problem: debugging embedded signal behavior without access to expensive lab equipment.

---

## Key Highlights

| Parameter | Value |
|---|---|
| Platform | Intel Cyclone IV (EP4CE6E22C8N) |
| Clock Constraint | 25 MHz (40 ns period) |
| Timing Status | Setup ✅ Hold ✅ (Timing Analyzer verified) |
| Interface | UART (hardware UART — no soft IP) |
| Waveform Output | VCD → GTKWave/ Modelsim |
| RTL Language | Verilog |
| Toolchain | Quartus Prime, GTKWave, Python 3, Modelsim |

---

## Architecture

```
Signal Input → Circular Buffer (RTL) → FSM Trigger Logic → UART TX → Python Host → VCD → GTKWave
```

### RTL Design Blocks

- **Circular Buffer** — Continuous signal capture using a ring buffer with configurable depth. Allows pre-trigger and post-trigger data retention without gaps.
- **Trigger FSM** — Finite state machine monitors incoming signal for a user-defined trigger condition. Once triggered, captures a fixed post-trigger window then halts.
- **UART Transmitter** — Streams captured buffer contents serially to the host machine at a baud rate matched to the 25 MHz system clock.
- **Python Host Script** — Receives UART data, reconstructs sample timing, and generates a standards-compliant `.vcd` file.

---

## Waveform Output

Captured waveform visualized in GTKWave from a live FPGA capture:

![Waveform Output](https://github.com/user-attachments/assets/2fe5ecb3-c28e-495e-900f-49349c2f585c)

---

## Design Decisions & Engineering Rationale

**Why a circular buffer?**
A circular buffer allows continuous capture without stalling the signal pipeline. Pre-trigger data is preserved automatically — critical for debugging transient conditions that occur before a trigger event.

**Why UART instead of JTAG/USB-FIFO?**
UART keeps the BOM cost at zero — any CP2102 or CH340 USB-UART adapter works. The tradeoff is bandwidth, which is acceptable given the 25 MHz sample rate and post-capture streaming model.

**Why 25 MHz clock constraint?**
The system is fundamentally UART-bandwidth-limited, not compute-limited. Constraining at 25 MHz ensures reliable timing closure without over-engineering the design. TimeQuest confirmed positive setup and hold slack at this constraint.

**Why Python for VCD generation?**
VCD is a text-based format — Python handles the byte-to-sample reconstruction and file generation cleanly with no external dependencies. The script is self-contained and cross-platform.

---

## Timing Verification

Timing closure verified using Quartus Prime TimeQuest Timing Analyzer:

- **Clock:** 25 MHz (40 ns period)
- **Setup slack:** Positive ✅
- **Hold slack:** Positive ✅

SDC constraint applied to the system clock domain. No unconstrained paths reported.

---

## Repository Structure

```
├── docs/
│   ├── Waveform.png            # Output Waveform
├── python/
│   └── capture.py              # UART capture + VCD generation script
├── rtl/
│   |── logic_analyzer.v
|   |── top.v                   # Top-level module
|   |──uart_tx.v                # UART transmitter (8N1)
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

python3 host/capture.py --port /dev/ttyUSB0 --baud 115200
gtkwave wave.vcd
```

---

## What This Project Demonstrates

- **RTL Design** — Synthesizable Verilog with FSM, memory structures, and serial interface
- **Timing Closure** — SDC constraints and TimeQuest analysis on a real device
- **Hardware-Software Integration** — FPGA RTL interfacing with a Python host over physical UART
- **System Thinking** — End-to-end design from signal capture to waveform visualization
- **Debugging Real Hardware** — Tested on physical Cyclone IV board, not just simulation

---

## Motivation

Commercial logic analyzers (SignalTap, Xilinx ILA) require tool-specific integration and consume FPGA fabric. This project implements an equivalent capture-and-stream architecture entirely in RTL — portable across any FPGA with a UART-capable pin, and fully open.

---

## Tools & Environment

| Tool | Purpose |
|---|---|
| Quartus Prime | Synthesis, P&R, Programming |
| Timing Analyzer | Static Timing Analysis |
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
