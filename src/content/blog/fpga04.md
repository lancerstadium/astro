---
title: FPGA_0x04
author: lancer
pubDatetime: 2024-03-03T15:42:16Z
slug: fpga-04
featured: false
draft: false
tags:
  - Architecture
  - FPGA
  - Vivado
  - Modelsim
description:
  "使用 Vivado 和 Modelsim 搭建 FPGA 开发环境"
---

## Table of contents


## 1 软件介绍

### 1.1 Vivado

Vivado是赛灵思（Xilinx）公司推出的一款集成化的FPGA设计工具套件，用于帮助工程师进行FPGA设计、验证和实现。Vivado提供了丰富的功能和工具，包括逻辑设计、综合、时序分析、布局布线、仿真等，可以帮助工程师快速、高效地完成FPGA设计工作。

Vivado支持多种Xilinx FPGA系列，包括Artix、Kintex、Virtex等，同时也支持高级综合（HLS）工具，使得工程师可以更方便地进行高层次的设计和优化。Vivado是一个强大而全面的FPGA设计工具，被广泛应用于通信、嵌入式系统、图像处理等领域。


### 1.2 Modelsim

Modelsim是Mentor公司开发的优秀的HDL语言仿真软件。它能提供友好的仿真环境，采用单内核支持VHDL和Verilog混合仿真的仿真器。它采用直接优化的编译技术、Tcl/Tk技术和单一内核仿真技术，编译仿真速度快且编译的代码与平台无关。

ModelSim有几种不同的版本：SE、PE、LE和OEM，其中SE是最高级的版本，而集成在 Actel、Atmel、Altera、Xilinx以及Lattice等FPGA厂商设计工具中的均是其OEM版本。


### 1.3 软件包

> 软件下载：
> 1. [Vivado | Xilinx](https://www.xilinx.com/products/tools/vivado.html)
> 2. [Vivado | Quark](https://pan.quark.cn/s/01996b0b2e69)
> 2. [Modelsim (free version)](https://www.intel.com/content/www/us/en/collections/products/fpga/software/downloads.html?edition=pro&platform=windows&download_manager=direct&product=modelsim_ae)
> 3. [Modelsim (Password: 82eh) | BaiduPan](https://pan.baidu.com/s/1vaMfrHw4IfamREKiVAsSGw)



## 参考文献

- [最详细的 Vivado 安装教程 | CSDN](https://blog.csdn.net/weixin_49457347/article/details/123643998)
- [Modelsim 安装步骤详解 | CSDN](https://blog.csdn.net/QWERTYzxw/article/details/115350715)
- [FPGA开发软件环境搭建 | Zhihu](https://zhuanlan.zhihu.com/p/605742464)