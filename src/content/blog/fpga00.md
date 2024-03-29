---
title: FPGA_0x00
author: lancer
pubDatetime: 2024-03-01T10:23:51Z
slug: fpga-00
featured: false
draft: false
tags:
  - Architecture
  - FPGA
description:
  "介绍 FPGA 的相关概念"
---


## Table of contents

## 1 模拟电路和数字电路

模拟电路处理的是模拟信号：在时间和数量上的变化是连续的，如温度；

数字电路处理的是数字信号：在时间和数量上的变化是离散的，如人数；

大规模和超大规模集成电路都是数字电路。


## 2 什么是可编程逻辑器件

可编程逻辑器件（*Programmable Logic Device, PLD*）：允许用户自信修改内部连接的集成电路，即 PLD 内部的电路结构可以通过编程来改变。

常见的 PLD 有可编程逻辑器件（*CPLD*）和现场可编程门阵列（*FPGA*），CPLD 是基于**乘积项**的与或逻辑阵列，FPGA 是基于**查找表**的逻辑门 CLB 阵列。


## 3 什么是 FPGA

现场可编程门阵列（*FPGA*）是一种可以通过编程来修改逻辑值的数字集成电路（芯片），不同于 *ASIC* 芯片，它是一个半成品集成电路，允许开发者进行无限次数的电路改写，大大降低了电子产品原型开发周期和成本。

相比于CPU和GPU，FPGA的主频很低，通常在100-200MHz。最新的FPGA可以运行在300MHz以上，但也很难超过400MHz。因此单纯就运算速度而言，基于FPGA的硬件设计必须有足够的并行度或其他优化手段才可以和CPU以及GPU匹敌。

相对于通用计算平台，FPGA的硬件设计冗余更小，提供相同的功能，只需要很低的功耗。低端的FPGA的功耗可以在5W以内，而高端的FPGA通常也不会超过100W。

> 注意：区分FPGA板卡和FPGA芯片，以及它们的型号，不要混用。

### 3.1 FPGA 内部结构

CLB 可编程模块由两个Slice组成，两个Slice根据LUT的不同分成 SliceM 和 SliceL：
1. SliceM (M: Memory)：内部 LUT 可读写，可实现移位寄存器和 DRAM 等存储功能，称为分布式存储，可以实现基本的查找表逻辑；
2. SliceL (L: Logic)：内部 LUT 只可读，只能实现基本的查找表逻辑。

> 一般情况下：
> - CLB 中比例 SliceL: SliceM = 2 : 1。
> - `1 CLB = 2 Slice = 2 * (4 * LUT + 3 * MUX + 1 * CARRY4 + 8 * FF)`


FPGA内部由一些相同的“块”构成，每个块内部又包含不同的列，每一列内部包含一种逻辑单元。逻辑单元之间通过互连线以及开关提供任意的连接方式。现代的FPGA主要由以下几种逻辑单元构成：

1. 查找表和寄存器 (LUT & register)
通常，查找表和寄存器会绑定在一起，任何组合逻辑都可以通过真值表的方式来实现。因此将真值表烧写到RAM中作为查找表是一种通用的实现逻辑的方式。

Xilinx的FPGA中通常采用6输入1输出（可配置为5输入2输出）的查找表作为基本的单元。对于需要更多输入的逻辑，可以采用查找表级联的形式来实现。查找表后面通常会级联寄存器，将组合逻辑的输出及时地寄存，以保证电路的整体性能。

![LUT & register](../../assets/images/fpga/lut.png)

在Xilinx的FPGA中，查找表和寄存器的比例通常是1:2。在不使用寄存器进行大量的数据存储时，通常寄存器的资源是足够的。而需要存储数据时，也可以将查找表配置为RAM来使用。FPGA中的LUT数量在几万到几十万不等，仅作为存储也有不小的规模。

> - 查找表的优点：灵活、延迟可控；
> - 当组合逻辑复杂时：需要级联实现，如果级数过大，回导致延时太大，一般采用插入寄存器的方法来切割组合逻辑，从而优化时序。


移位寄存器 SRL，移位寄存器内的数据可以在移位脉冲（时钟信号）的作用下依次左移或者右移。

![SRL32](../../assets/images/fpga/srl32.png)

应用：存储数据、串并转换、序列检测、数值计算、数据处理等等，是数字系统中非常常用的时序部件之一。

SliceM中的查找表可读写，就是用来设计存储和移位使用的。

两个SRL32与一个MUX2，可以级联成最高支持64位的SRL。

> 布线：4个LUT刚好同在一个Slice布线方便延迟短；
> 同步：引脚Q需要接到触发器FF，共享同一时钟；


分布式 DRAM（*Distributed RAM*）：使用SliceM中的超招标实现，利用查找表为电路实现存储器。

> 注意：
> 使用DRAM实现大规模存储器会占用大量LUT，建议仅在需要小规模存储时使用分布式RAM。

![DRAM64](../../assets/images/fpga/ram64.png)

一个SliceM中4个LUT、2个F7MUX、1个FMUX，最大可以实现一个深度为256的单口DRAM，超过这个空间就要级联。

```verilog
reg [5:0] dram64x6[63:0];

always @(posedge wclk)
    if(we)
        dram64x6[addr] <= d;

assgin o = dram64x6[addr];

```

> 注意：
> - 分布式RAM用于所有深度为64或更少的情况，除非设备缺少SLICEM或逻辑资源，因为DRAM在资源、性能和功能方面更高效；
> - 对于大于64位小于128位深度，取决于：额外BRAM可用性、延迟要求、数据宽度（>16使用BRAM）、性能要求（DRAM有更短的Tco时间和更少的布局限制）


2. 多路选择器（MUX）

多路选择器MUX是一个多输入、单输出的组合逻辑电路，一个输入的多路选择器就是一个路的数字开关，可以根据通道选择控制信号的不同，从门个输入中选取一个输出到公共的输出端。7系列FPGA中的每个Slice含有3个双输入选择器(MUX2),分别为F7AMUX、F7BMUX、F8MUX.

为什么FPGA中只有MUX2？

![MUX8](../../assets/images/fpga/mux8.png)

> 注意：
> - 不使用LUT6实现MUX2来代替固定的MUX2：因为性能问题；
> - 在实现MUX16的过程中使用LUT6来代替固定的MUX2：这样固定便于布线，4个查找表到达MUX2路径上的走线线延迟差小（几乎等长）。




3. 块缓存 (Block RAM)

块缓存(Block RAM)是FPGA中最重要的存储单元，通常用BRAM来简称。最新的FPGA可包含接近100MB的BRAM，远远超过一般的CPU或GPU的cache大小。FPGA中的缓存通常是真双端口(true dual port)缓存，包含两组读写口，每一组端口可以时分复用地读或写。

![BRAM](../../assets/images/fpga/bram.png)

FPGA中的缓存通常为统一大小的块。Xilinx的缓存的基本粒度为36bit宽，深度为512，视为0.5个BRAM。实际使用时可以根据需要配置成更窄的位宽以及更大的深度。当设计使用的缓存大小超过0.5个BRAM时，综合工具会自动将其映射到多个BRAM上。最新的Xilinx FPGA还包含了72-bit宽，深度为4096的Ultra RAM来针对大容量片上存储的需求。

4. 数字处理单元 (DSP)

数字处理单元(DSP)是用来进行整数的数学运算的。其基本的功能包括整数的加法、累加、乘法等。可以以流水线的形式完成完成`(A+D)*B+C`的功能。下图Xilinx的FPGA中DSP的基本结构。

![DSP](../../assets/images/fpga/dsp.png)

尽管这样的功能也可以用查找表和寄存器来实现，但是采用DSP单元，在面积与时序上都会更优。一些其他功能的IP，例如浮点计算的IP，也会尽可能借助DSP单元来实现功能。



## 4 FPGA 与 CPU 的区别

FPGA 与 CPU 的区别在于：
1. 是否改变硬件内部结构：FPGA 编程是通过改变硬件电路的连接方式来完成任务的，而 CPU 的编程并不改变内部的连接结构。
2. 是否并行：CPU 需要进行取指，译码，执行的过程，这个过程是串行的；FPGA 是并行的，处理速度比 CPU 快得多。


目前很多的FPGA，如Xilinx的Zynq 7000和UltraScale MPSoC以及Versal系列，都在芯片上集成了ARM架构的CPU。

一方面基于CPU可以快速搭建DEMO。另一方面，一些不利于FPGA实现的功能可以在片上集成的CPU上实现，两者形成互补，为方案设计提供更大的选择空间。

Xilinx的术语中，通常将SoC中的CPU称为PS（*Processing System*），将FPGA部分称为PL（*Programmable Logic*）。


## 5 什么是 Verilog

`Verilog`是用于设计 FPGA 电路的一门语言，可以用类C语言风格编写电路设计代码，然后使用 FPGA 厂商提供的工具链进行综合，仿真，模拟，最后生成可以在FPGA上面运行的电路。


## 6 FPGA 开发流程

1. 设计文档：明确功能、资源需求、模块划分。
2. 逻辑设计：使用硬件描述语言（*HDL*）在不同的层次对数字电路的结构，功能和行为进行描述。
3. 电路实现：通过综合工具，将HDL所描述的电路转换为门级电路网表，然后将其与某种工艺的基本原件一一对应起来，最后通过布局布线工具转换为电路布线借结构。
4. 系统验证：使用仿真工具或者现场调试工具进行功能和正确性的验证。


## 参考资料

- [simple-fpga-guide | Github](https://github.com/GkyHub/simple-fpga-guide/blob/master/doc/fpga_intro.md)
- [verilog-notes | Github](https://github.com/lyp365859350/Verilog/blob/master/Notes.md)