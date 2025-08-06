# Hardware-Implementation-of-an-Image-Decompressor
Project Summary:
This project is a full hardware implementation of an image decompressor based on the custom .mic8 image compression specification, built for the Altera DE2 FPGA board. The decompressor is designed to process 320x240 pixel compressed image data and display the decompressed image on a monitor via VGA output. The entire pipeline is implemented using Verilog and runs entirely on hardware, with no software post-processing once the data is received.

Objective:
The goal was to build a complete system that receives a compressed image from a host PC, stores it in SRAM, decompresses the image using custom digital logic, and outputs it through a VGA controller in real time. This involved applying knowledge from digital systems, finite state machines, memory interfacing, and signal processing.

Architecture Overview:
The system is broken down into multiple hardware modules that interact through carefully coordinated control logic:

1. UART Interface
Compressed .mic8 image files are sent from a PC over a UART serial connection. A hardware UART receiver module on the DE2 board captures the incoming serial data byte-by-byte and stores it into external SRAM. Custom control logic ensures reliable reception and memory writing.

2. SRAM Interface
External SRAM is used to buffer both the incoming compressed data and the output decompressed image. Separate read and write controllers manage access to SRAM for different modules: one for writing compressed data, one for reading during decompression, and another for VGA output. Access is carefully synchronized to avoid collisions.

3. Decompression Pipeline
  The decompression process is modeled closely after standard image codecs like JPEG but simplified for hardware implementation. The pipeline includes:
  
  Lossless Decoding: Parses the .mic8 stream and reconstructs the quantized frequency data using a custom scan pattern and coding format.
  
  Dequantization: Applies the inverse of quantization using predefined quantization matrices (Q0 or Q1) to approximate the original DCT coefficients.
  
  Inverse Discrete Cosine Transform (IDCT): Converts 8x8 blocks of frequency-domain values back into spatial-domain pixel values using fixed-point matrix math.
  
  Upsampling and Color Space Conversion: U and V channels (which were downsampled) are interpolated, and YUV data is converted back to RGB using matrix multiplication.

4. VGA Display Controller
Reads the RGB pixel values from SRAM and sends them to the VGA interface. Displays the full 320x240 decompressed image on a monitor. VGA timing, sync signals, and pixel mapping are handled through a dedicated Verilog module.

Tools and Technologies Used:

Verilog HDL for all hardware modules

Quartus II for FPGA synthesis and programming

ModelSim for simulation and debugging

UART protocol for serial data transfer from PC

External SRAM for intermediate storage

Python/C host scripts for sending image data over UART

Key Learning Outcomes:

Implementing a hardware-based image decompression pipeline
Designing finite state machines for control and data flow

Working with color spaces, signal transforms, and compression techniques

Managing shared memory access between independent hardware modules

Handling real-time video output through VGA from FPGA
