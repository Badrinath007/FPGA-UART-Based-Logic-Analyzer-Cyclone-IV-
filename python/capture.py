import serial

# Open serial
ser = serial.Serial('/dev/ttyUSB0', 115200)

# Read data safely
data = ser.read(128)

print("Captured bytes:", len(data))

#print(list(data[:20]))

# =========================
# VCD WRITER
# =========================
def write_vcd(data, filename="wave.vcd"):
    with open(filename, "w") as f:
        f.write("$timescale 1ns $end\n")
        f.write("$scope module logic_analyzer $end\n")
        f.write("$var wire 8 c count $end\n")
        f.write("$upscope $end\n")
        f.write("$enddefinitions $end\n")

        time = 0
        prev = None

        for val in data:
            if val != prev:  # avoid redundant writes
                f.write(f"#{time}\n")
                f.write(f"b{val:08b} c\n")
                prev = val
            time += 10

# =========================
# CALL FUNCTION
# =========================
write_vcd(data)

print("Waveform generated and execute using gtkwave: wave.vcd")
