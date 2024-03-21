---
title: FPGA_0x08
author: lancer
pubDatetime: 2024-03-05T14:28:21Z
slug: fpga-08
featured: false
draft: false
tags:
  - Architecture
  - FPGA
  - Verilog
  - Math
  - IP
description:
  "查表法实现 Verilog 复杂数学函数（幂、log、sin、cos）"
---

## Table of Contents


## 1 查找表 LUT

查找表(*Look-Up Table, LUT*)就是一个预先存储好结果的数据表。通过访问这张预先存储好结果的数据表，可以快速的获取不同输入的输出结果。

查找表可以免去运算的过程，尤其对于复杂的运算更是可以大大减少运算开销和运行时间。其缺点就是会消耗过多的系统存储空间（存储空间大小与组合逻辑的输入端口数呈二的整数次幂关系）。

故我们可以使用其他软件计算函数的离散数据，组成查找表信息，以python为例，收集`log`函数信息：

```python
import numpy as np

for i in range(0, 256):
    print('8\': log = {};'.format(
        i,
        np.array(255 * np.log(i / 255), dtype=np.uint8)
    ))

```

## 2 使用查找表

在Xilinx FPGA 中，ROM（只读存储器）和 RAM（随机存储器）可以使用四种资源来实现，分别是 BRAM（块RAM）、LUT（查找表）、分布式RAM 和 URAM（超大容量RAM）。可以使用 `rom_style` 或 `ram_style` 属性来强制规定使用的资源类型：

1. `(*ram_style="block"*)`：表示使用 Block RAM（BRAM）实现 RAM，Block RAM 是 FPGA 中的硬件块，具有较大的存储容量和快速的读写速度；
2. `(*ram_style="reg"*)`：表示使用寄存器实现 RAM，寄存器是 FPGA 中的基本存储单元，速度快但容量有限；
3. `(*ram_style="distributed"*)`：表示使用分布式RAM 实现 RAM，分布式RAM是分布在 FPGA 的查找表（LUT）中的小型存储器，用于存储少量数据；
4. `(*ram_style="uram"*)`：表示使用 URAM 实现 RAM，URAM 是 FPGA 中的超大容量RAM，具有更高的存储容量和更快的速度，适合需要大容量存储的应用。

当RAM小于10K bit时，分布式RAM在功耗和速度上更有优势；当设计中LUT利用率很高时，如果Block RAM资源利用率不高，可以把分布式RAM转换为Block RAM，从而释放出一部分LUT资源。

类似地，rom_style则是引导综合工具将ROM采用不同的资源实现。其可选值有两个：`block`和`distributed`。这是因为UltraRAM不能用做ROM。

一个简单的 Verilog 代码示例：展示了如何使用 Block RAM 实现一个简单的 ROM 模块，根据输入的地址从 ROM 中读取数据并输出。

```verilog
module rom (
    input clk,
    input rd_en,
    input [7:0] rd_addr,
    output reg [7:0] data_out
);

(*rom_style="block"*) reg [7:0] data; // ROM 数据存储在 Block RAM 中

always @(posedge clk) begin
    if (rd_en) begin
        case (rd_addr)
            8'd0: data <= 8'b00000000; // Address 0
            8'd1: data <= 8'b00000001; // Address 1
            8'd2: data <= 8'b00000010; // Address 2
            8'd3: data <= 8'b00000011; // Address 3
            default: data <= 8'b00000000; // Default case
        endcase
    end
end

assign data_out = data; // 输出 ROM 数据

endmodule


```

> 除了 ROM 和 RAM 的实现方式外，还可以利用其他 FPGA 提供的资源 IP（知识产权）来实现特定功能。


## 3 COE文件 & MIF文件

COE文件和MIF文件都用于导入存储器ROM或RAM的存储数据，但是它们的格式和语法有些不同。

通过 COF、MIF 文件，可以方便地描述存储器的初始化数据，便于在 FPGA 设计中进行存储器的初始化。

### 3.1 COE文件

COE（Coefficient）文件是一种常用于描述存储器初始化数据的文件格式，主要用于 Xilinx Vivado 等工具。COE 文件包含两个主要部分：头信息和内存初始化数据：
1. 头信息部分：
   - MEMORY_INITIALIZATION_RADIX：定义数据类型的基数。有效值为 2（二进制）、10（十进制）、16（十六进制）。
   - MEMORY_INITIALIZATION_VECTOR：定义存储器初始化数据的开始标志。
2. 内存初始化数据部分：
   - 存储器初始化数据以指定基数的数字形式列出，用空格、逗号或回车符进行分隔。
   - 每行表示存储器中的一个地址，其后紧跟初始化的数据值。

下面是一个 COE 文件的示例：

```
; Sample COE file
; Memory initialization data for a 4x8 ROM

MEMORY_INITIALIZATION_RADIX=16;
MEMORY_INITIALIZATION_VECTOR=

00, 01, 02, 03, 04, 05, 06, 07,
08, 09, 0A, 0B, 0C, 0D, 0E, 0F,
10, 11, 12, 13, 14, 15, 16, 17,
18, 19, 1A, 1B, 1C, 1D, 1E, 1F;
```

在这个示例中，COE 文件描述了一个 4x8 ROM 的初始化数据。头信息部分指定了数据类型基数为十六进制（16），然后在 MEMORY_INITIALIZATION_VECTOR 中列出了 ROM 的初始化数据，每行表示一个地址，后面是对应的十六进制数据值。


### 3.2 MIF文件

MIF（Memory Initialization File）文件是一种常用于描述存储器初始化数据的文件格式，通常用于 Quartus 等工具。MIF 文件包含两个主要部分：元信息和内存初始化数据。

MIF 文件格式梳理如下：

1. 元信息部分：
   - DEPTH：存储器的深度，即存储多少个数据。
   - WIDTH：存储器的数据位宽，即每个数据有多少位。
   - ADDRESS_RADIX：设置地址基值的进制表示，可以设为 BIN（二进制）、OCT（八进制）、DEC（十进制）、HEX（十六进制）。
   - DATA_RADIX：设置数据基值的进制表示，与 ADDRESS_RADIX 类似。

2. 内存初始化数据部分：
   - CONTENT BEGIN：数据区开始标志。
   - 内存初始化数据：按照地址顺序列出每个地址对应的数据值。
   - END：数据区结束标志。

下面是一个 MIF 文件的示例：

```
WIDTH=8;
DEPTH=256;
ADDRESS_RADIX=DEC;
DATA_RADIX=HEX;

CONTENT BEGIN
0 : 00;
1 : 01;
2 : 02;
3 : 03;
4 : 04;
5 : 05;
...
255 : FF;
END;
```

在这个示例中，MIF 文件描述了一个 256 个地址、每个数据位宽为 8 位的存储器的初始化数据。元信息部分指定了存储器的位宽、深度以及地址和数据的进制表示。在 CONTENT BEGIN 和 END 之间列出了每个地址对应的数据值，以地址和数据值的形式表示。


## 4 块随机存储器 BRAM

使用Xilinx或Inter的`BRAM IP`可以实现ROM。这里以vivado为例，打开`IP catalog`中，输入BRAM,打开`Block Memory Generator IP`。



## 参考资料

- [verilog基于查找表的8位格雷码转换 | CSDN](https://blog.csdn.net/cengqiu4314/article/details/134931650)
- [“万能”的查表法 | CSDN](https://blog.csdn.net/Reborn_Lee/article/details/104955374)