---
title: FPGA_0x05
author: lancer
pubDatetime: 2024-03-04T12:16:16Z
slug: fpga-05
featured: false
draft: false
tags:
  - Architecture
  - FPGA
  - IP
description:
  "介绍常用 IP 核"
---

## Table of contents

## 1 IP 核介绍

在 ASIC 或 FPGA 中，IP （*Intellectual Property*）被定义为**预先设计好的电路功能模块**。IP 核在数字电路中常用于设计参数可修改、功能比较复杂的模块（如：ROM、RAM、FIR滤波器、SDRAM控制器、PCIE接口等），其他用户可以直接调用这些模块。

对着设计规模的增大，复杂度提高，使用 IP 核设计电子系统方便引用、修改元器件功能，从而提高开发效率。

IP 核根据产品交付的方式，分为如下三种：
1. **软核**：HDL（*Hardware Description Language*）硬件描述语言所编写的模块，可进行参数调整、复用性强，布线、布局灵活，设计周期短、投入少；
2. **固核**：一般为网表形式，是完成了综合的模块，可以预布线特定信号或分配特定的布线资源；
3. **硬核**：一般为版图形式，是完成提供设计最终阶段产品——掩膜（Mask），缺乏灵活性、可移植性，易于实现对 IP 核的保护。

> 注意：
> IP 核往往不能跨平台使用，IP 核不透明，看不到内部核心代码，其次，定制 IP 核一般需要额外收费。


## 2 常用 IP 核

在不同应用场景下，生成工具提供如下类别的 IP 核：
1. **数学运算模块**：包括累加器、乘加器、乘累加器、计数器、加/减法器、实/复数乘法器、除法器、CORDIC 算法器、DSP48 宏和浮点数操作器；
2. **存储器构造模块**：包括块存储器和分布式存储器、先入先出存储器（FIFO）和移位寄存器；




## 参考资料

- [FPGA开发中常用的IP核 | CSDN](https://blog.csdn.net/ARM_qiao/article/details/124973685)