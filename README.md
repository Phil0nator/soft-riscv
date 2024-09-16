# Soft RISC-V Core
This repository is split into two primary sections:
1. The first is the RTL directory. This includes the RTL, testbenches, and constraints files necessary
   to implement the core on a Digilent Basys-3 development board using Vivado.
2. The second is the software directory. This includes necessary scripts and files to enable compiling
   into a binary file that can be inserted directly into the BRAM on the RISC-V core.
   It also includes C libraries that provide an abstraction layer to interact with the memory mapped peripherals.
   This directory also includes an Etch-a-Sketch test program.

## The Core
The core itself is a 32-bit RISC-V core that only implements the integer subset of the RISC-V ISA and meets timing
at the Basys-3's default clock of 100MHz. The core itself is relatively isolated and all external interfaces are controlled
by the memory module.

![image](https://github.com/user-attachments/assets/d0d37983-6ef3-487a-b91c-56f56cb06a38)

## Peripherals
The exact memory layout of the core can be found in the Soft RISC-V Memory Layout Excel file in the topmost 
directory of this repository. The memory mapped peripherals include:
### Four digit 7-Segment display
  The four digit 7-segment display is mapped to address 0x04 and includes hardware BCD conversion
  so that no conversion needs to be made in software. This peripheral has predictable behavior
  at values < 9999 when provided with an unsigned value but at values larger than 9999 or with 
  integers it will not display the correct values.
### LEDs
  The LEDs are mapped to address 0x08 with the first 16 bits mapping to an LED. The 16 MSBs
  are unused. A 1 written to a bit turns its corresponding LED on and a 0 turns it off.
  On the Basys-3 the LEDs are mapped such that the LSB of address 0x08 is routed to the 
  rightmost LED (LED0).
### Pushbuttons
  The pushbuttons are mapped to address 0x0C and are connected such that from LSB to MSB
  they are left, right, up, down. The center button on the basys-3 is used for a reset line. 
  The 28 MSBs of address 0x0C are unused.
### Switches
  The switches are mapped to address 0x10 and are connected similarly to the LEDs in that
  the 16 MSBs are unused and the LSB (0th) is connected to the rightmost switch (SW0).
### 64-bit timer
  The 64-bit timer is mapped to address 0x1C and 0x20. The lower 32-bits are at addres 0x1C
  and the upper 32-bits are at address 0x20. This timer can be seeded to any value but will 
  always count up without pause at 100MHz. 
### DMA VGA Controller
  The DMA VGA Controller is the most resource intensive peripheral in the design. This peripheral
  displays a 120 x 160 8-bit color image on a VGA display using the VGA connector on the basys-3.
  This peripheral has three separate memory spaces. The first is a control register mapped to memory 
  address 0x14. The other two are frame buffers that the control register swaps between. Frame buffer 0 
  is at memory location 0x100000 - 0x104B00. and Frame buffer 1 is at memory location 0x200000 - 0x204B00.
  The VGA controller is always active and always reading from one of the two frame buffers. The active
  frame buffer is controlled by the LSB (0th) bit of the VGA control register. A 0 at this bit
  selects frame buffer 0 and a 1 selects frame buffer 1. The frame buffers are read out by the VGA
  such that each byte in the memory space holds a pixel and as the memory address increases the pixels
  go left to right, top to bottom. Within a byte each pixel is G-G-B-B-B-R-R-R with leftmost being
  the MSB and rightmost being LSB. 

   
