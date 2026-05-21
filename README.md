# Micro UART Design in Verilog

## Overview

This project implements a Micro UART (Universal Asynchronous Receiver Transmitter) using Verilog HDL. The design supports asynchronous serial communication between digital systems without using a shared clock.

The UART consists of:

* UART Transmitter (TX)
* UART Receiver (RX)
* Baud Rate Generator
* Reference Model for Verification

The transmitter converts parallel data into serial format, while the receiver converts serial data back into parallel form.

---

# Features

* Parameterized data width
* FSM-based UART TX and RX
* Start and Stop bit generation
* LSB-first transmission
* 16x oversampling support
* Double flip-flop synchronization
* Busy and Done status indication
* Synthesizable RTL design

---

# UART Frame Format

text
| START | DATA | STOP |


* Start Bit = 0
* Stop Bit = 1
* Data transmitted LSB first

---

# Working Principle

## UART Transmitter

The transmitter:

1. Waits for transmit enable signal
2. Sends start bit
3. Shifts serial data bit-by-bit
4. Sends stop bit
5. Generates transmission complete signal

---

## UART Receiver

The receiver:

1. Detects start bit
2. Samples incoming serial data
3. Reconstructs parallel data
4. Checks stop bit
5. Generates receive ready signal

---

# Baud Generator

The baud generator divides the system clock to generate UART sampling clock required for transmission and reception.

---

# Applications

* FPGA communication
* Embedded systems
* Serial debugging
* Microcontroller interfacing
* Bluetooth/GPS communication
* IoT devices

---

# Tools Used

* Verilog HDL
* Xilinx Vivado
* ModelSim / QuestaSim

---

# Conclusion

This Micro UART project demonstrates serial communication implementation using Verilog HDL with FSM-based architecture, baud rate generation, synchronization, and reliable data transmission/reception suitable for FPGA-based systems.
