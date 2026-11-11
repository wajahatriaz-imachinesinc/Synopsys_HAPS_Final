# Design and Verification of a 5-Stage Pipelined Processor with R-Format Instruction using Synopsys HAPS-100 Protocompiler

## Introduction:
In this project, we aim to design and verify a 5-stage pipelined processor with R-format instruction using the Synopsys HAPS-100 protocompiler. The pipeline processor is a fundamental building block of many modern microprocessors, and the R-format instruction is a type of instruction commonly used in MIPS (Microprocessor without Interlocked Pipeline Stage) architectures.


## Objective:
The objective of this project is to design and verify a 5-stage pipelined processor with R-format instruction using Synopsys HAPS-100 protocompiler. The HAPS-100 protocompiler will be used to validate the RTL design of the processor and run the partition flow to end up with a system-generated output.


## Block Diagram

+ The block diagram is as below:
    + ![](https://i.imgur.com/yWWlmaw.png)

+ This CPU read the 32-bit instruction and support below R-format instructions
    + ![](https://i.imgur.com/mj3dEyU.png)

## The Schemetic of FPGA_A and FPGA_B:

![](https://i.imgur.com/8OFaqeU.png)

+ FPGA_A
    + ![](https://i.imgur.com/OaEseei.png)
+ FPGA_B
    + ![](https://i.imgur.com/0ZPZRll.png)
    + ![](https://i.imgur.com/9uA2F13.png)
        + Adder
        + ![](https://i.imgur.com/jRBF2Op.png)


## Methodology:
The project will be divided into two main phases: design and verification. In the design phase, we will use Verilog to design the 5-stage pipelined processor with R-format instruction. The design will include modules for instruction fetch, instruction decode, instruction execute, memory access, and write-back.

In the verification phase, we will use Synopsys HAPS-100 protocompiler to validate the RTL design of the processor. We will use the HAPS-100 protocompiler to run the partition flow, which will partition the design into multiple parts and generate a system-generated output. We will then perform functional verification to ensure that the design meets the required specifications.

## Expected Outcome:
The expected outcome of this project is a 5-stage pipelined processor with R-format instruction that is fully verified using Synopsys HAPS-100 protocompiler. The design will meet the required specifications, and the verification results will be presented in a report.

## Timing Report and other Experimental Results

+ System Generate Result
    + ![](https://i.imgur.com/wKAJvV6.png)
+ The `.bit` file is generate by this flow.
    + Since we partition the design into two part, there are 2 `.bit` would be generate in the directory.
    + ![](https://i.imgur.com/GV7Rm0L.png)
    + ![](https://i.imgur.com/adOuqju.png)

+ Design Timing Summary
    + Since we partition the design into two part, there are 2 timing report would be generate in the directory.
        + Setup time: Check WNS and TNS in `FB1_uA_timing_summary.txt` and FB1_uB_timing_summary.txt`
            + ![](https://i.imgur.com/czDzdkG.png)
            + ![](https://i.imgur.com/FWv3GKr.png)
        + Hold time: Check WNS and THS in `FB1_uA_timing_summary_Min.txt` and `FB1_uB_timing_summary_Min.txt`
            + ![](https://i.imgur.com/CwCAfVL.png)
            + ![](https://i.imgur.com/cNckWIX.png)
    + Finally, all user specified timing constraints are met (no negative value).

## Conclusion & Reflection:

This project aims to design and verify a 5-stage pipelined processor with R-format instructions using the Synopsys HAPS-100 protocompiler. The project will provide hands-on experience in designing and verifying complex digital systems using industry-standard tools. The outcome of the project will be a verified design of a fundamental building block of modern microprocessors, which can serve as a starting point for further research and development.

During this project, I spent a lot of time resolving a schematic bug. My design is optimized by HAPS, so that my total schemetic diagram is optimized by below figure.
![](https://i.imgur.com/Rjxohwf.png)

After referencing the HAPS document, I added the comment /* synthesis syn_black_box */ in my RTL code, as shown in the figure below, and this flow worked smoothly.
![](https://i.imgur.com/fPYQYe2.png)

In the end, all timing constraints were met, which proves the functionality of my design and its operation on HAPS.

---

## Learning Path: From Setup to Mastery

If you're taking over this project or want to understand the HAPS-200 flow from scratch, follow this structured learning path:

### **Phase 1: Fundamentals (Days 1-2)**

**Start with the reference manual:**
- Read: `/projects/users/wriaz/Synopsys_HAPS_Final/docs/haps-200_12f_reference_manual_v2.pdf`
- Focus on:
  1. **Chapters 1-2**: Architecture overview
  2. **Chapter 3**: HAPS-200 12F hardware specs (FPGAs F0-F11, connectors, voltages)
  3. **Chapter 4**: HapsTrak connectors and I/O basics
  4. **Chapter 5**: Clock distribution

**Key concepts to understand:**
- What is HAPS? (Hardware emulation/prototyping platform)
- What are FPGAs F0-F11? (12 user FPGA slots per FlexBoard)
- What are HapsTrak connectors? (60-pin I/O connectors)
- VCCO voltages (1.0V, 1.1V, 1.2V, 1.35V)

### **Phase 2: Configuration Basics (Days 3-4)**

**Learn Tcl scripting** (lightweight, ~2 hours):
- `board.tss` files are Tcl scripts
- Reference: https://www.tcl.tk/man/tcl8.6/tutorial/Tcl.html (first 3 sections)

**Study the reference design:**
```
/projects/users/wriaz/clone_111026/proto/haps/partition/haps200.tss
```
Focus on:
1. `board_system_create` - How to define HAPS system and add boards
2. `board_system_configure` - Clock, voltages, I/O configuration
3. `board_system_create -interconnect` - Inter-FPGA connections

### **Phase 3: Building Block Examples (Days 5-6)**

**Create simple configs from scratch:**

**Example 1: Minimal config (1 FPGA, 1 clock)**
```tcl
board_system_create -haps -name IM_HAPS200
board_system_create -add HAPS200_6F_2 -name FB1 -stack_through none
board_system_configure -clk_src PLL -frequency 22M -name GCLK_USER_CLK
board_system_configure -clock {FB1.F0.CLK1} GCLK_USER_CLK
```

**Example 2: Multi-FPGA config (Add F1, interconnect)**
```tcl
board_system_create -interconnect -manual CON_CABLE_50_HT3 \
  -name FB1_F0_F1 -connector {FB1.F0_X1 FB1.F1_X1}
board_system_configure -clock {FB1.F1.CLK1} GCLK_USER_CLK
board_system_configure -voltage {FB1.F0_X1 FB1.F1_X1} 1.2
```

**Example 3: DDR4 memory config**
```tcl
board_system_create -interconnect -manual DDR4_S32GBF_HT3 \
  -name DDR4_FB1F0 -connector {FB1.F0_X1 FB1.F0_X2 FB1.F0_X3}
board_system_configure -voltage {FB1.F0_X1 FB1.F0_X2 FB1.F0_X3} 1.2
```

### **Phase 4: Partition Constraints (Days 7-8)**

**Learn partition.pcf:**
- `assign_cell` - Map logic to specific FPGAs
- `assign_global_net` - Assign clocks to logic
- `bin_attribute` - Lock unused FPGAs
- `reset_synchronize` - Handle async resets

Study reference:
```
/projects/users/wriaz/clone_111026/proto/haps/partition/haps200.pcf
```

### **Phase 5: Complete Flow (Days 9-10)**

**Understand run.tcl steps:**
1. `database load RCPU -technology HAPS-200` - Initialize database
2. `launch uc` - Compile RTL with ProtoCompiler
3. `run pre_partition` - Check board.tss validity
4. `run partition` - Map design to FPGAs
5. `run system_route` - Route inter-FPGA connections
6. `run system_generate` - Generate Vivado scripts
7. `launch protocompiler` - Synthesize per FPGA
8. `launch vivado` - Place & Route per FPGA

### **Recommended Study Schedule:**

```
Week 1:
  Mon: Manual chapters 1-5 (2 hrs)
  Tue: Tcl basics (2 hrs)
  Wed: Study reference board.tss (3 hrs)
  Thu: Build minimal configs (3 hrs)
  Fri: Multi-FPGA + DDR4 (3 hrs)

Week 2:
  Mon: Learn partition.pcf (3 hrs)
  Tue: Build partition constraints (3 hrs)
  Wed: Understand run.tcl flow (2 hrs)
  Thu: Run complete flow with your design (4 hrs)
  Fri: Debug and optimize (4 hrs)
```

### **Hands-On Projects:**

1. **Project 1**: Create a 2-FPGA config with shared clock
2. **Project 2**: Add DDR4 memory to one FPGA
3. **Project 3**: Partition a simple adder across 2 FPGAs
4. **Project 4**: Full compile flow with timing analysis

### **Key Files to Study:**

| File | Purpose |
|------|---------|
| `board.tss` | HAPS system configuration (FPGAs, clocks, interconnects) |
| `partition.pcf` | Design partition constraints (cell-to-FPGA mapping) |
| `run.tcl` | ProtoCompiler workflow (compile, partition, generate) |
| `design.fdc` | Design constraints (frequency, timing) |
| `uc_compile.utf` | RTL compilation config |

### **Common Connector Naming Convention:**

| Format | Example | Meaning |
|--------|---------|---------|
| `FB#.F#_X#` | `FB1.F0_X1` | FlexBoard 1, FPGA Slot 0, HapsTrak connector 1 |
| | `FB1.F1_X16` | FlexBoard 1, FPGA Slot 1, HapsTrak connector 16 |
| | `FB1.F0_X30` | FlexBoard 1, FPGA Slot 0, HapsTrak connector 30 |

### **Architecture Reference:**

- **HAPS-200 6F_2**: 6 FPGA slots (F0-F5) per FlexBoard, 2 FlexBoards stackable
- **HAPS-200 12F**: 12 FPGA slots (F0-F11) per module
- **Each FPGA**: 18 HapsTrak 4 connectors (54 pins each)
- **Voltages**: 1.0V, 1.1V, 1.2V, 1.35V (HapsTrak 4)
- **Inter-connect**: Every FPGA connects to every other FPGA internally
