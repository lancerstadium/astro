---
title: FPGA_0x09
author: lancer
pubDatetime: 2024-03-06T11:32:51Z
slug: fpga-09
featured: false
draft: false
tags:
  - Architecture
  - FPGA
  - Verilog
  - Digital Circuit
description:
  "介绍 Verilog 时序约束"
---


## Table of Contents


## 1 时序约束步骤

四大步骤：
1. 设置时钟
2. input delays
3. output delays
4. 时序例外



## 1.1 时钟

1. 输入时钟：
   1. 输入管脚是 `clk`
   2. 输入管脚是差分
   3. 输入管脚是 GT 或恢复时钟

2. PLL 等衍生时钟

3. 自己分频的时钟



## 1.2 input delays

1. 系统同步

2. 源同步（常用）：时钟 + 数据
   1. SDR
      1. 参考数据手册
      2. 示波器测量
   2. DDR
      1. 中心对齐：示波器测量
      2. 边沿对齐：示波器测量

3. 有数据无时钟



## 1.3 output delays


