# FPGA UART-Based Logic Analyzer (Cyclone IV)

A lightweight FPGA-based logic analyzer with circular buffering and trigger-based capture, enabling real-time signal debugging over UART and waveform visualization using GTKWave.

## Features

- Circular buffer-based continuous signal capture
- Trigger-based acquisition (pre and post-trigger data)
- UART-based data streaming (low-cost hardware)
- Waveform visualization via VCD + GTKWave
- Implemented on Intel Cyclone IV FPGA

## Architecture

Capture → Circular Buffer → Trigger → UART → Python → VCD → GTKWave

## Waveform Output

<img width="999" height="635" alt="waveform" src="https://github.com/user-attachments/assets/2fe5ecb3-c28e-495e-900f-49349c2f585c" />

## How it works

1. FPGA continuously captures signals into a circular buffer
2. Trigger condition stops capture after defined samples
3. Data is streamed via UART
4. Python script converts data into VCD format
5. GTKWave visualizes the waveform

## Usage

### FPGA
- Compile using Quartus Prime
- Program Cyclone IV board

### Python
```bash
python3 capture.py
gtkwave wave.vcd
```
### 📌 Tech stack

```markdown

- Verilog (RTL Design)
- Python (Data Capture + VCD Generation)
- Quartus Prime
- GTKWave
```

## Motivation

This project was built as a low-cost alternative to commercial logic analyzers like SignalTap/ILA.
