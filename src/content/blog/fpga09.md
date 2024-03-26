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


使用`Vivado`的`Sources`文件管理器直接创建新的`.xdc`文件或者添加已有的`.xdc`文件。
1. 点击`+`号；
2. 选择`Add or create constrints`点击`next`；
3. 点击`Create Files`；
4. 数据文件名点击`OK`即可在`Constrains`中看到新建的文件；
5. 双击打开`.xdc`文件，写入约束语句即可。

在综合（*Synthesis*）后点击`Constrainsts Wizard`（时序约束向导），其顺序是：主时钟约束、衍生时钟约束、输入延迟约束、输出延迟约束、时序例外约束、异步时钟约束等顺序依次创建时钟约束的。

`Edit Timing Constrints`时序约束编辑器提供可视化约束修改，更容易使用。

时序约束有四大步骤：
1. 设置时钟
2. input delays
3. output delays
4. 时序例外

> 1. 按顺序去索引，找到对应情况，按照要求去约束；
> 2. 开始只配置时钟；
> 3. 时钟完全通过后再配置input/output delays；
> 4. 时序例外最后完工再配置；


## 1.1 时钟

1. 输入时钟：
   1. 输入管脚是 `clk`：
    ```
    create_clock -name SysClk -period 10 -waveform {0 5} [get_ports Clk]
    ```

   2. 输入管脚是差分
    ```
    create_clock -name clk_200 -period 5 [get_ports clk_200_p]
    ```

   3. 输入管脚是 GT 或恢复时钟
    ```
    create_clock -name txclk -period 6.667 [get_pins GT/TXOUTCLK]
    ```


2. PLL 等衍生时钟：工具自动推导，一般无需约束。

```
create_clock -name clk_200 -period 5 [get_ports clk_200_p]
create_generated_clock -name my_clk_name [get_pins mmcm0/CLKOUT] \
    -source [get_ports mmcm0/CLKIN]\
    -master_clock clk_200

# Altera
# derive_pll_clocks
```


3. 自己分频的时钟
```
create_clock -name CLK1 -period 5 [get_ports CKP1]
create_generated_clock -name my_clk_name [get_pins REGA/Q] \
    -source [get_ports CKP1] -divide_by 2
```

> 1. 自定义约束覆盖工具约束
> 2. 后约束覆盖先约束
> 3. 共存：-add


## 1.2 input delays

1. 系统同步：器件共用时钟，FPGA与其他器件之间只传输数据


2. 源同步（常用）：时钟 + 数据同步传输
   1. SDR：上升沿采样
      1. 参考数据手册
      2. 示波器测量
   2. DDR：上下沿采样
      1. 中心对齐：数据变化在时钟中心，示波器测量
      2. 边沿对齐：示波器测量

3. 有数据无时钟



## 1.3 output delays

1. 系统同步：器件共用时钟，FPGA与其他器件之间只传输数据

2. 源同步（常用）：时钟 + 数据同步传输
   1. SDR：上升沿采样
      1. 参考数据手册
      2. 示波器测量
   2. DDR：上下沿采样
      1. 中心对齐：数据变化在时钟中心，示波器测量
      2. 边沿对齐：示波器测量



## 1.4 时序例外

1. 多周期路径


2. 不需要检查的路径
   1. 常量及伪常量
   2. 互斥的时钟和路径：双向端口
   3. 异步时钟


3. 组合电路延时

